import SwiftData

@Model
class Task {
    var title: String
    var dueDate: Date
    var priority: Int
    var isCompleted: Bool
    var notes: String
    var naturalLanguagePrompt: String?
    @Attribute(.transformable(parser: NaturalLanguageParser.self)) var parsedComponents: [String: Any]?
    var recurrence: RecurrenceRule?
    var completionDate: Date?
    
    init(title: String, dueDate: Date = .now, priority: Int = 1, isCompleted: Bool = false, notes: String = "") {
        self.title = title
        self.dueDate = dueDate
        self.priority = priority
        self.isCompleted = isCompleted
        self.notes = notes
    }
    
    func toggleCompletion() {
        isCompleted.toggle()
        completionDate = isCompleted ? Date() : nil
    }
}
