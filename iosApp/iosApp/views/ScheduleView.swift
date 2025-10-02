import SwiftUI
import shared

struct ScheduleView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                Text("INFO TODO")
            }
            .navigationTitle("Program")
        }
    }
}
