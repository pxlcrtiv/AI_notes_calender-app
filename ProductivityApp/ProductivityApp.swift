import SwiftUI

@main
struct ProductivityApp: App {
    @State private var dataManager = DataManager()
    @State private var hapticEngine = HapticEngine()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dataManager)
                .environment(\.hapticEngine, hapticEngine)
                .alert("iCloud Error", isPresented: $dataManager.showSyncError) {
                    Button("OK") {}
                } message: {
                    Text("Please ensure you're signed into iCloud and have enabled sync for this app in Settings.")
                }
        }
        .modelContainer(dataManager.modelContainer)
    }
}
