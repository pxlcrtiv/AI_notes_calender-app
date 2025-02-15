import SwiftUI
import Charts

struct WeeklyTrendCard: View {
    @Environment(AnalyticsEngine.self) private var analytics
    
    var body: some View {
        CardContainer(title: "Weekly Progress") {
            Chart(Array(analytics.metrics.weeklyTrend.enumerated()), id: \.0) { index, count in
                LineMark(
                    x: .value("Week", analytics.metrics.trendAnnotations[index]),
                    y: .value("Completed", count)
                )
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Week", analytics.metrics.trendAnnotations[index]),
                    y: .value("Completed", count)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.blue.opacity(0.1))
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .week)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .frame(height: 150)
        }
    }
}
