import SwiftUI
import Charts

struct CompletionRateCard: View {
    @Environment(AnalyticsEngine.self) private var analytics
    
    var body: some View {
        CardContainer(title: "Completion Rate") {
            Chart {
                BarMark(
                    x: .value("Completed", analytics.metrics.tasksCompleted),
                    y: .value("Type", "Completed")
                )
                BarMark(
                    x: .value("Pending", analytics.metrics.totalTasks - analytics.metrics.tasksCompleted),
                    y: .value("Type", "Pending")
                )
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 100)
        }
    }
}
