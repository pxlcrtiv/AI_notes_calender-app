import Foundation
import SwiftData
import UserNotifications

@MainActor
class AnalyticsEngine: ObservableObject {
    @Published var metrics = ProductivityMetrics()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    func refreshMetrics(tasks: [Task]) {
        metrics.tasksCompleted = tasks.filter { $0.isCompleted }.count
        metrics.totalTasks = tasks.count
        
        let completedTasks = tasks.filter { $0.isCompleted }
        
        // Calculate average completion time
        let totalDuration = completedTasks
            .compactMap { $0.completionDate?.timeIntervalSince($0.dueDate) }
            .reduce(0, +)
        metrics.averageCompletionTime = completedTasks.isEmpty ? 0 : totalDuration / Double(completedTasks.count)
        
        // Calculate peak productivity hours
        let hourCounts = completedTasks.reduce(into: Array(repeating: 0, count: 24)) { counts, task in
            guard let completionDate = task.completionDate else { return }
            let hour = Calendar.current.component(.hour, from: completionDate)
            counts[hour] += 1
        }
        metrics.peakProductivityHours = hourCounts
            .enumerated()
            .sorted { $0.element > $1.element }
            .prefix(3)
            .map { $0.offset }
        
        // Calculate estimated time savings
        let pendingTasks = tasks.filter { !$0.isCompleted }
        metrics.estimatedTimeSavings = Double(pendingTasks.count) * metrics.averageCompletionTime
        
        // Calculate weekly trend
        let weeks = Calendar.current.datesGroupedByWeek(from: tasks)
        metrics.weeklyTrend = weeks.map { week in
            Double(week.tasks.filter(\.isCompleted).count)
        }
        metrics.trendAnnotations = weeks.map { $0.rangeLabel }
    }
    
    func recommendFocusSessions() -> [FocusSession] {
        let hourWeights = metrics.peakProductivityHours
            .enumerated()
            .map { index, count in (index, Double(count)) }
        
        var sessions = [FocusSession]()
        var currentStart: Int? = nil
        var currentWeight = 0.0
        
        for hour in 0..<24 {
            let weight = hourWeights.first { $0.0 == hour }?.1 ?? 0
            
            if weight > 0.5 * metrics.peakProductivityHours.max()! {
                if currentStart == nil {
                    currentStart = hour
                }
                currentWeight += weight
            } else if let start = currentStart {
                sessions.append(FocusSession(
                    startHour: start,
                    endHour: hour,
                    intensity: currentWeight / Double(hour - start)
                ))
                currentStart = nil
                currentWeight = 0
            }
        }
        
        return sessions.sorted { $0.intensity > $1.intensity }
    }
    
    func scheduleFocusNotifications() {
        notificationCenter.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                self.requestNotificationPermission()
                return
            }
            self.createNotifications()
        }
    }
    
    private func requestNotificationPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted { self.createNotifications() }
        }
    }
    
    private func createNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        
        for session in recommendFocusSessions().prefix(3) {
            let content = UNMutableNotificationContent()
            content.title = "Focus Time: \(session.timeRange)"
            content.body = "Your peak productivity window starts soon!"
            content.sound = .default
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: DateComponents(hour: session.startHour - 1, minute: 55),
                repeats: true
            )
            
            let request = UNNotificationRequest(
                identifier: "focus-\(session.id.uuidString)",
                content: content,
                trigger: trigger
            )
            notificationCenter.add(request)
        }
    }
}
