import SwiftUI
import shared

struct AppStatePicker: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var localState: AppState?
    @State private var showRestartMessage = false

    var body: some View {
        Picker("App State", selection: $localState) {
            Text("Limited").tag(AppState.limited as AppState?)
            Text("Pre Event").tag(AppState.preEvent as AppState?)
            Text("Active Event").tag(AppState.activeEvent as AppState?)
            Text("Post Event").tag(AppState.postEvent as AppState?)
            Text("Auto").tag(nil as AppState?)
        }
        .pickerStyle(.menu)
        .onChange(of: localState) { newValue in
            appViewModel.appConfigService.setAppStateOverride(state: newValue)
            withAnimation(.easeIn(duration: 0.2)) {
                showRestartMessage = true
            }
        }
        .onAppear {
            localState = appViewModel.appConfigService.getAppStateOverride()
        }
    }
}

#Preview("AppState Picker") {
    AppStatePicker()
        .environmentObject(AppViewModel())
        .padding()
        .background(Color.background)
        .preferredColorScheme(.dark)
}
