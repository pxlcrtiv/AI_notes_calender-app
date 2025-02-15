import Foundation

extension Calendar {
    func datesGroupedByWeek(from tasks: [Task]) -> [(rangeLabel: String, tasks: [Task])] {
        let completedTasks = tasks.filter(\.isCompleted)
        guard !completedTasks.isEmpty else { return [] }
        
        let dateIntervals = DateInterval(
            start: completedTasks.map(\.completionDate!).min()!,
            end: Date()
        )
        
        var weeks = [Date]()
        enumerateDates(startingAfter: dateIntervals.start, matching: DateComponents(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime) { date, _, stop in
            guard let date = date, date < dateIntervals.end else { stop = true; return }
            weeks.append(date)
        }
        
        return weeks.map { weekStart in
            let weekEnd = date(byAdding: .day, value: 6, to: weekStart)!
            let weekTasks = completedTasks.filter {
                $0.completionDate! >= weekStart && $0.completionDate! <= weekEnd
            }
            let label = "\(weekStart.formatted(.dateTime.day().month())) - \(weekEnd.formatted(.dateTime.day().month()))"
            return (label, weekTasks)
        }
    }
}
