import SwiftUI
import shared

struct HomeHeaderView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(height: 32)
            Text("\(Strings.App.shared.TITLE) \(eventYear)")
                .font(.title3)
                .fontWeight(.semibold)
        }
    }
    
    private var eventYear: String {
        return appViewModel.getAppConfigService().getEventYear()
    }
}

@available(iOS 18, *)
#Preview("Home header", traits: .sizeThatFitsLayout) {
    HomeHeaderView()
        .environmentObject(AppViewModel())
        .padding(Spacing.md)
        .background(.background)
}
