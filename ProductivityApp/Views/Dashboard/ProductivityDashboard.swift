import SwiftUI
import Charts

struct ProductivityDashboard: View {
    @Environment(AnalyticsEngine.self) private var analytics
    @Query private var tasks: [Task]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                CompletionRateCard()
                TimeManagementCard()
                WeeklyTrendCard()
                ProductivityHeatmap()
                FocusScheduleCard()
                TaskCategoryBreakdown()
            }
            .padding()
        }
        .navigationTitle("Productivity Insights")
        .onAppear { analytics.refreshMetrics(tasks: tasks) }
        .onChange(of: tasks) { analytics.refreshMetrics(tasks: tasks) }
    }
}

#Preview {
    ProductivityDashboard()
        .environment(AnalyticsEngine())
}
