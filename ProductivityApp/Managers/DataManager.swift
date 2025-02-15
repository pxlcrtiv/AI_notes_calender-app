import SwiftData
import SwiftUI

@MainActor
class DataManager: ObservableObject {
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: Task.self, Event.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    // Task management
    func addTask(title: String, dueDate: Date) -> Task {
        let task = Task(title: title, dueDate: dueDate)
        modelContainer.mainContext.insert(task)
        return task
    }
    
    // Event management
    func addEvent(title: String, date: Date) -> Event {
        let event = Event(title: title, date: date)
        modelContainer.mainContext.insert(event)
        return event
    }
}
