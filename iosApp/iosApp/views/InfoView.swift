import SwiftUI
import SwiftUIBackports
import shared

struct InfoView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
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
        .navigationTitle(Strings.Tabs.shared.ABOUT_FESTIVAL)
        .navigationBarTitleDisplayMode(.inline)
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
                    icon: "door.left.hand.open",
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
