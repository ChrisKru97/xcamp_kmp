import SwiftUI
import shared

struct InfoView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                Text(StringsKt().common.infoTodo)
            }
            .navigationTitle(StringsKt().titles.info)
        }
    }
}
