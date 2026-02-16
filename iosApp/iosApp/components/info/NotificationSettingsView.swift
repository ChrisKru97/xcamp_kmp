import SwiftUI
import shared
import UserNotifications

struct NotificationSettingsView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    @State private var newsEnabled: Bool = false
    @State private var scheduleMode: ScheduleNotificationMode = .off
    @State private var prayerDayEnabled: Bool = false
    @State private var showPermissionAlert: Bool = false

    private var notificationService: NotificationService { appViewModel.notificationService }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                newsNotificationSection
                prayerDayNotificationSection
                scheduleNotificationSection
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.md)
        }
        .navigationTitle(Strings.Notifications.shared.TITLE)
        .navigationBarTitleDisplayMode(.inline)
        .alert(Strings.Notifications.shared.PERMISSION_DENIED_TITLE, isPresented: $showPermissionAlert) {
            Button(Strings.Notifications.shared.OPEN_SETTINGS) {
                openSettings()
            }
            Button(Strings.Notifications.shared.CANCEL, role: .cancel) {}
        } message: {
            Text(Strings.Notifications.shared.PERMISSION_DENIED_MESSAGE)
        }
        .onAppear {
            loadPreferences()
        }
    }

    private func loadPreferences() {
        let preferences = notificationService.getPreferences()
        newsEnabled = preferences.newsEnabled
        scheduleMode = preferences.scheduleMode
        prayerDayEnabled = preferences.prayerDayEnabled
    }

    private var newsNotificationSection: some View {
        toggleSection(
            title: Strings.Notifications.shared.NEWS_ENABLED,
            description: Strings.Notifications.shared.NEWS_ENABLED_DESCRIPTION,
            isOn: $newsEnabled,
            prefType: "news"
        )
    }

    private var prayerDayNotificationSection: some View {
        toggleSection(
            title: Strings.Notifications.shared.PRAYER_DAY_ENABLED,
            description: Strings.Notifications.shared.PRAYER_DAY_ENABLED_DESCRIPTION,
            isOn: $prayerDayEnabled,
            prefType: "prayer_day"
        )
    }

    @ViewBuilder
    private func toggleSection(
        title: String,
        description: String,
        isOn: Binding<Bool>,
        prefType: String
    ) -> some View {
        Toggle(isOn: isOn) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.body)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .onChange(of: isOn.wrappedValue) { newValue in
            logNotificationPrefChange(prefType: prefType, enabled: newValue)
            updatePreferences()
        }
        .padding()
        .card()
    }

    private var scheduleNotificationSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(Strings.Notifications.shared.SCHEDULE_NOTIFICATIONS)
                    .font(.body)
                Text("Upozorníme vás 15 minut předem")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
                
            Picker("", selection: $scheduleMode) {
                Text(Strings.Notifications.shared.MODE_OFF).tag(ScheduleNotificationMode.off)
                Text(Strings.Notifications.shared.MODE_FAVORITES).tag(ScheduleNotificationMode.favorites)
                Text(Strings.Notifications.shared.MODE_ALL).tag(ScheduleNotificationMode.all)
            }
            .pickerStyle(.segmented)
            .onChange(of: scheduleMode) { newValue in
                logNotificationPrefChange(prefType: "schedule", enabled: newValue != .off)
                updatePreferences()
            }
        }
        .padding()
        .card()
    }

    private func updatePreferences() {
        Task {
            do {
                let hasPermission = try await notificationService.hasPermission()

                if !hasPermission.boolValue {
                    do {
                        let _ = try await notificationService.requestPermission()
                    } catch {
                        let appError = AppError.from(error)
                        if case AppError.notificationPermission = appError {
                            showPermissionAlert = true
                            let preferences = notificationService.getPreferences()
                            newsEnabled = preferences.newsEnabled
                            scheduleMode = preferences.scheduleMode
                            prayerDayEnabled = preferences.prayerDayEnabled
                        }
                        return
                    }
                }

                let newPreferences = NotificationPreferences(
                    newsEnabled: newsEnabled,
                    scheduleMode: scheduleMode,
                    prayerDayEnabled: prayerDayEnabled
                )
                notificationService.updatePreferences(preferences: newPreferences)

                await refreshAllNotifications()
            } catch {
                await refreshAllNotifications()
            }
        }
    }

    private func refreshAllNotifications() async {
        let preferences = notificationService.getPreferences()

        if preferences.prayerDayEnabled {
            await refreshPrayerNotification()
        }

        if scheduleMode != .off {
            await refreshScheduleNotifications()
        } else {
            try? await notificationService.cancelAllScheduleNotifications()
        }
    }

    private func refreshPrayerNotification() async {
        guard appViewModel.appState == .limited || appViewModel.appState == .preEvent else {
            try? await notificationService.cancelPrayerNotification()
            return
        }

        let startDate = appViewModel.remoteConfigService.startDate
        try? await notificationService.schedulePrayerNotifications(startDate: startDate)
    }

    private func refreshScheduleNotifications() async {
        guard appViewModel.appState == .activeEvent else { return }

        do {
            try await notificationService.refreshScheduleNotifications()
        } catch {
            print("Failed to refresh notifications: \(error.localizedDescription)")
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    private func logNotificationPrefChange(prefType: String, enabled: Bool) {
        Analytics.shared.logEvent(name: AnalyticsEvents.shared.NOTIFICATION_PREF_CHANGE, parameters: [
            AnalyticsEvents.shared.PARAM_PREF_TYPE: prefType,
            AnalyticsEvents.shared.PARAM_ENABLED: String(enabled)
        ])
    }
}

#Preview {
    NavigationView {
        NotificationSettingsView()
            .environmentObject(AppViewModel())
    }
}
