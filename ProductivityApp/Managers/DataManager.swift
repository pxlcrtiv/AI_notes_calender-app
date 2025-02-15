import SwiftData
import SwiftUI
import CloudKit

@MainActor
class DataManager: ObservableObject {
    let modelContainer: ModelContainer
    var modelContext: ModelContext { modelContainer.mainContext }
    @Published var showSyncError = false
    private var syncObserver: NSObjectProtocol?
    
    init() {
        let schema = Schema([Task.self, Event.self])
        let cloudIdentifier = "iCloud.com.yourdomain.ProductivityApp"
        let config = ModelConfiguration(
            cloudKitContainerIdentifier: cloudIdentifier,
            allowsSave: true,
            groupContainer: .none
        )
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        setupCloudKitObserver()
    }
    
    private func setupCloudKitObserver() {
        syncObserver = NotificationCenter.default.addObserver(
            forName: .NSPersistentCloudKitContainerEventChanged,
            object: nil,
            queue: .main
        ) { notification in
            if let event = notification.userInfo?[NSStoreNotificationKey] as? NSPersistentCloudKitContainerEvent {
                self.handleSyncEvent(event)
            }
        }
    }
    
    private func handleSyncEvent(_ event: NSPersistentCloudKitContainerEvent) {
        if event.error != nil {
            showSyncError = true
        }
    }
    
    // Task management
    func addTask(title: String, dueDate: Date, recurrence: RecurrenceRule?) -> Task {
        let task = Task(title: title, dueDate: dueDate)
        task.recurrence = recurrence
        modelContext.insert(task)
        
        if let recurrence = recurrence {
            scheduleNextRecurringTask(basedOn: task)
        }
        return task
    }
    
    private func scheduleNextRecurringTask(basedOn task: Task) {
        guard let recurrence = task.recurrence else { return }
        
        let nextDate: Date
        switch recurrence.frequency {
        case .daily: nextDate = Calendar.current.date(byAdding: .day, value: 1, to: task.dueDate)!
        case .weekly: nextDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: task.dueDate)!
        case .monthly: nextDate = Calendar.current.date(byAdding: .month, value: 1, to: task.dueDate)!
        case .yearly: nextDate = Calendar.current.date(byAdding: .year, value: 1, to: task.dueDate)!
        }
        
        let newTask = Task(title: task.title, dueDate: nextDate)
        newTask.recurrence = recurrence
        modelContext.insert(newTask)
    }
    
    // Event management
    func addEvent(title: String, date: Date) -> Event {
        let event = Event(title: title, date: date)
        modelContainer.mainContext.insert(event)
        return event
    }
}
