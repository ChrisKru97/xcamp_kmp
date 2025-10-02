import SwiftUI
import shared

struct ScheduleView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                Text(StringsKt().common.infoTodo)
            }
            .navigationTitle(StringsKt().titles.schedule)
        }
    }
}
