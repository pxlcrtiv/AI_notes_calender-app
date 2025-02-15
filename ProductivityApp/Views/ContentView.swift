import SwiftUI

struct ContentView: View {
    @Environment(DataManager.self) private var dataManager
    
    var body: some View {
        TabView {
            TaskListView()
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }
            
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(DataManager())
}
