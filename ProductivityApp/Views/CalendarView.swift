import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(DataManager.self) private var dataManager
    @Query private var events: [Event]
    @Query private var tasks: [Task]
    
    @State private var selectedDate = Date()
    @State private var showingNewEventSheet = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // Month header
                CalendarHeaderView(selectedDate: $selectedDate)
                
                // Date grid
                CalendarGridView(selectedDate: $selectedDate, events: events, tasks: tasks)
                
                // Daily schedule
                DailyScheduleView(selectedDate: $selectedDate, events: events, tasks: tasks)
            }
            .navigationTitle("Calendar")
            .toolbar {
                Button(action: { showingNewEventSheet.toggle() }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingNewEventSheet) {
                NewEventView()
            }
        }
    }
}

struct CalendarHeaderView: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        HStack {
            Button { selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate)! } label: {
                Image(systemName: "chevron.left")
            }
            
            Text(selectedDate.formatted(.dateTime.year().month(.wide)))
                .font(.title2)
                .frame(maxWidth: .infinity)
            
            Button { selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate)! } label: {
                Image(systemName: "chevron.right")
            }
        }
        .padding()
    }
}

struct CalendarGridView: View {
    @Binding var selectedDate: Date
    var events: [Event]
    var tasks: [Task]
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(datesInMonth(), id: \.self) { date in
                CalendarDayCell(date: date, 
                              selectedDate: $selectedDate,
                              events: events.filter { Calendar.current.isDate($0.date, inSameDayAs: date) },
                              tasks: tasks.filter { Calendar.current.isDate($0.dueDate, inSameDayAs: date) })
            }
        }
        .padding()
    }
    
    private func datesInMonth() -> [Date] {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: selectedDate)
        let year = calendar.component(.year, from: selectedDate)
        
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate) else { return [] }
        return calendar.generateDates(inside: monthInterval, matching: DateComponents(hour: 0, minute: 0, second: 0))
    }
}

struct CalendarDayCell: View {
    @Environment(DataManager.self) private var dataManager
    let date: Date
    @Binding var selectedDate: Date
    var events: [Event]
    var tasks: [Task]
    
    var body: some View {
        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
        let hasRecurringTasks = tasks.contains { $0.recurrence != nil }
        
        Button(action: { selectedDate = date }) {
            VStack {
                Text(Calendar.current.component(.day, from: date).formatted())
                    .foregroundColor(isSelected ? .white : .primary)
                    
                if !events.isEmpty || !tasks.isEmpty {
                    HStack(spacing: 2) {
                        ForEach(events.prefix(3), id: \.self) { _ in
                            Circle().fill(.blue).frame(width: 4)
                        }
                        ForEach(tasks.prefix(3), id: \.self) { task in
                            Circle()
                                .fill(task.recurrence != nil ? Color.orange : Color.green)
                                .frame(width: 4)
                        }
                    }
                }
                
                if hasRecurringTasks {
                    Image(systemName: "repeat")
                        .font(.system(size: 8))
                        .foregroundColor(.orange)
                }
            }
            .frame(width: 40, height: 40)
            .background(isSelected ? Color.blue : Color.clear)
            .clipShape(Circle())
        }
        .onDrop(of: [.text], delegate: TaskDropDelegate(date: date, dataManager: dataManager))
    }
}

struct TaskDropDelegate: DropDelegate {
    let date: Date
    @Environment(DataManager.self) private var dataManager
    @Environment(\.hapticEngine) private var haptic
    
    func performDrop(info: DropInfo) -> Bool {
        guard let item = info.itemProviders(for: [.text]).first else { return false }
        
        item.loadItem(forTypeIdentifier: .text) { data, _ in
            if let idString = data as? String,
               let taskID = PersistentIdentifier(idString),
               let task = dataManager.modelContainer.mainContext.model(for: taskID) as? Task {
                task.dueDate = date
            }
        }
        haptic.playDragHaptic()
        return true
    }
}

struct DailyScheduleView: View {
    @Binding var selectedDate: Date
    var events: [Event]
    var tasks: [Task]
    
    var body: some View {
        List {
            Section("Events") {
                ForEach(events.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) { event in
                    EventRowView(event: event)
                }
            }
            
            Section("Tasks Due") {
                ForEach(tasks.filter { Calendar.current.isDate($0.dueDate, inSameDayAs: selectedDate) }) { task in
                    TaskRowView(task: task)
                }
            }
        }
    }
}

struct NewEventView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(\.dismiss) private var dismiss
    @State private var newEventTitle = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Event Title", text: $newEventTitle)
                Button("Create Event") {
                    dataManager.addEvent(title: newEventTitle, date: .now)
                    dismiss()
                }
            }
            .navigationTitle("New Event")
        }
    }
}

struct EventRowView: View {
    let event: Event
    
    var body: some View {
        Text(event.title)
    }
}

struct TaskRowView: View {
    let task: Task
    
    var body: some View {
        Text(task.title)
    }
}

#Preview {
    CalendarView()
        .environment(DataManager())
}
