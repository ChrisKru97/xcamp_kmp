import SwiftUI
import shared

struct InfoView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                contentView
            }
        } else {
            contentView
        }
    }

    private var contentView: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                emergencySection
                contactSection
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.xxl)
        }
        .background(Color.background)
        .navigationTitle(Strings.Tabs.shared.INFO)
        .modifier(iOS16TabBarBackgroundModifier())
    }

    private var emergencySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(Strings.Info.shared.IMPORTANT_INFO)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .padding(.horizontal, Spacing.xs)

            VStack(spacing: Spacing.sm) {
                EmergencyPill(
                    icon: "cross.case.fill",
                    title: Strings.Info.shared.MEDICAL_HELP_TITLE,
                    description: Strings.Info.shared.MEDICAL_HELP_TEXT
                )

                EmergencyPill(
                    icon: "arrow.up.forward.square.fill",
                    title: Strings.Info.shared.LEAVING_CAMP_TITLE,
                    description: Strings.Info.shared.LEAVING_CAMP_TEXT
                )
            }
        }
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
