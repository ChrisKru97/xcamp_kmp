import SwiftUI
import shared

struct InfoView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    importantInfoSection
                    contactLinksSection
                }
                .padding(Spacing.md)
            }
            .background(Color.background)
            .navigationTitle(Strings.Tabs.shared.INFO)
        }
    }

    private var importantInfoSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                sectionHeader(icon: "cross.case.fill", title: Strings.Info.shared.IMPORTANT_INFO)

                VStack(spacing: Spacing.sm) {
                    importantInfoCard(
                        icon: "cross.case.fill",
                        title: Strings.Info.shared.MEDICAL_HELP_TITLE,
                        text: Strings.Info.shared.MEDICAL_HELP_TEXT
                    )

                    importantInfoCard(
                        icon: "arrow.up.forward.square",
                        title: Strings.Info.shared.LEAVING_CAMP_TITLE,
                        text: Strings.Info.shared.LEAVING_CAMP_TEXT
                    )
                }
            }
        }
    }

    private var contactLinksSection: some View {
        VStack(spacing: Spacing.sm) {
            ForEach(infoLinks, id: \.type) { link in
                InfoLinkCard(link: link)
            }
        }
    }

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            Spacer()
        }
    }

    private func importantInfoCard(icon: String, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.orange)
                .padding(Spacing.sm)
                .background(Color.orange.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                Text(text)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(Spacing.md)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.medium)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }

    private var infoLinks: [InfoLink] {
        return appViewModel.getLinksService().getInfoLinks()
    }
}

@available(iOS 18, *)
#Preview("Info View", traits: .sizeThatFitsLayout) {
    InfoView()
        .environmentObject(AppViewModel())
}
