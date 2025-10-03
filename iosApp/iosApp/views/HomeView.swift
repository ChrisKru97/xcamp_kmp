import SwiftUI
import shared

struct HomeView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    if shouldShowCountdown {
                        CountdownView(targetDateString: eventDateString)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    if mainInfo.isEmpty == false {
                        Text(mainInfo)
                            .padding()
                            .withDynamicGlassEffect()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.background))
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image("logo").resizable().scaledToFit().frame(height: 40)
                        Text("\(Strings.App.shared.TITLE) \(eventYear)").font(.title).fontWeight(.semibold)
                    }.padding()
                }
            }
        }
    }

    private var mainInfo: String {
        return appViewModel.getRemoteConfigService().getMainInfo()
    }

    private var shouldShowCountdown: Bool {
        appViewModel.appState == .preEvent || appViewModel.appState == .limited
    }

    private var eventDateString: String {
        return appViewModel.getRemoteConfigService().getStartDate()
    }

    private var eventYear: String {
        let year = TimeUtils.shared.getYearFromDateString(dateString: eventDateString)
        return String(year)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}
