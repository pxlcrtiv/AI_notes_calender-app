import SwiftData

@Model
class Task {
    var title: String
    var dueDate: Date
    var priority: Int
    var isCompleted: Bool
    var notes: String
    
    init(title: String, dueDate: Date = .now, priority: Int = 1, isCompleted: Bool = false, notes: String = "") {
        self.title = title
        self.dueDate = dueDate
        self.priority = priority
        self.isCompleted = isCompleted
        self.notes = notes
    }
}
