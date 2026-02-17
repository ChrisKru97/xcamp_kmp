import SwiftUI
import shared
import Firebase
import FirebaseCrashlytics

struct InfoView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var router: AppRouter
    @State private var dataCollectionEnabled = AppPreferences.shared.getDataCollectionEnabled()

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                emergencySection
                notificationsSection
                dataCollectionSection
                contactSection
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.xxl)
        }
        .navigationTitle(Strings.Tabs.shared.ABOUT_FESTIVAL)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var emergencySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(Strings.Info.shared.IMPORTANT_INFO)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .padding(.horizontal, Spacing.xs)

            VStack(spacing: Spacing.sm) {
                EmergencyPill(
                    icon: "cross.case.fill",
                    title: Strings.Info.shared.MEDICAL_HELP_TITLE,
                    description: Strings.Info.shared.MEDICAL_HELP_TEXT
                )

                EmergencyPill(
                    icon: "door.left.hand.open",
                    title: Strings.Info.shared.LEAVING_CAMP_TITLE,
                    description: Strings.Info.shared.LEAVING_CAMP_TEXT
                )
            }
        }
    }

    private var notificationsSection: some View {
        Button {
            router.push("notification-settings", type: .notificationSettings)
        } label: {
            HStack(spacing: Spacing.md) {
                Image(systemName: "bell.fill")
                    .font(.title3)
                    .foregroundStyle(Color.accent)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(Strings.Notifications.shared.TITLE)
                        .font(.body)
                        .foregroundStyle(.primary)

                    Text(Strings.Notifications.shared.NEWS_ENABLED)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
            .padding()
        }
        .glassButton()
    }

    private var dataCollectionSection: some View {
        Toggle(isOn: $dataCollectionEnabled) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(Strings.DataCollection.shared.TOGGLE_TITLE)
                    .font(.body)
                Text(Strings.DataCollection.shared.SECTION_FOOTER)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .onChange(of: dataCollectionEnabled) { newValue in
            AppPreferences.shared.setDataCollectionEnabled(enabled: newValue)
            configureFirebaseWithConsent(newValue)

            Analytics.shared.logEvent(
                name: "data_collection_changed",
                parameters: ["enabled": String(newValue)]
            )
        }
        .padding()
        .card()
    }

    private func configureFirebaseWithConsent(_ enabled: Bool) {
        Analytics.setAnalyticsCollectionEnabled(enabled)
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(enabled)
    }

    private var contactSection: some View {
        ContactGrid(links: infoLinks)
    }

    private var infoLinks: [InfoLink] {
        return appViewModel.linksService.getInfoLinks()
    }
}

#Preview("Info View") {
    InfoView()
        .environmentObject(AppViewModel())
}
