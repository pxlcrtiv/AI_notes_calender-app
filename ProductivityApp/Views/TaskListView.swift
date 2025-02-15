import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(DataManager.self) private var dataManager
    @Query private var tasks: [Task]
    @State private var newTaskInput = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Add task (e.g. 'Lunch with Amy next Thursday')", text: $newTaskInput)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit(createTaskFromNaturalLanguage)
                    
                    Button(action: createTaskFromNaturalLanguage) {
                        Image(systemName: "text.badge.plus")
                    }
                }
                .padding()
                
                List {
                    ForEach(tasks) { task in
                        TaskRowView(task: task)
                    }
                }
                .navigationTitle("Tasks")
                .toolbar {
                    Button(action: addTask) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    private func addTask() {
        let newTask = dataManager.addTask(title: "New Task", dueDate: .now)
    }
    
    private func createTaskFromNaturalLanguage() {
        let (title, date, recurrence) = NaturalLanguageParser.parseTask(from: newTaskInput)
        let newTask = dataManager.addTask(
            title: title,
            dueDate: date ?? .now,
            recurrence: recurrence
        )
        newTask.priority = NaturalLanguageParser.detectPriority(in: newTaskInput)
        newTaskInput = ""
    }
}

struct TaskRowView: View {
    @Bindable var task: Task
    @Environment(\.hapticEngine) private var haptic
    @Environment(DataManager.self) private var dataManager
    
    var body: some View {
        HStack {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(task.isCompleted ? .green : .secondary)
                .onTapGesture {
                    task.toggleCompletion()
                }
            
            VStack(alignment: .leading) {
                HStack {
                    TextField("Task title", text: $task.title)
                        .font(.headline)
                    if task.recurrence != nil {
                        Image(systemName: "repeat")
                            .foregroundColor(.blue)
                            .accessibilityLabel("Recurring task")
                    }
                }
                DatePicker("Due Date", selection: $task.dueDate)
                    .labelsHidden()
            }
        }
        .onDrag {
            haptic.playDragHaptic()
            return NSItemProvider(object: task.persistentModelID.uuidString as NSString)
        }
        .contextMenu {
            if task.recurrence != nil {
                Button("Skip Next Occurrence") {
                    skipNextRecurrence()
                }
                Button("Stop Recurrence") {
                    task.recurrence = nil
                }
            }
        }
    }
    
    private func skipNextRecurrence() {
        guard let recurrence = task.recurrence else { return }
        
        let nextDate = Calendar.current.date(
            byAdding: recurrence.frequency.calendarComponent,
            value: 1,
            to: task.dueDate
        ) ?? task.dueDate
        
        let skippedTask = Task(
            title: task.title,
            dueDate: nextDate,
            recurrence: nil
        )
        dataManager.modelContext.insert(skippedTask)
    }
}

extension RecurrenceRule.Frequency {
    var calendarComponent: Calendar.Component {
        switch self {
        case .daily: return .day
        case .weekly: return .weekOfYear
        case .monthly: return .month
        case .yearly: return .year
        }
    }
}

#Preview {
    TaskListView()
        .environment(DataManager())
}
