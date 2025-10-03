import SwiftUI
import shared

struct HomeView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    if shouldShowCountdown {
                        CountdownView(targetDate: eventStartDate)
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

    private var eventStartDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startDateString = appViewModel.getRemoteConfigService().getStartDate()
        return formatter.date(from: startDateString)?.addingTimeInterval(46800) ?? Date()
    }
    
    private var eventYear: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: eventStartDate)
    }
}
