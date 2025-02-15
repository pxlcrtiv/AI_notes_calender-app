import SwiftUI
import Charts

struct TimeManagementCard: View {
    @Environment(AnalyticsEngine.self) private var analytics
    
    var body: some View {
        CardContainer(title: "Time Management") {
            VStack(alignment: .leading) {
                Text("Avg. Completion Time:")
                Text(formatTimeInterval(analytics.metrics.averageCompletionTime))
                    .font(.title.bold())
                
                Text("Estimated Time Savings:")
                    .padding(.top)
                Text(formatTimeInterval(analytics.metrics.estimatedTimeSavings))
                    .font(.title.bold())
            }
        }
    }
    
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: interval) ?? "N/A"
    }
}
