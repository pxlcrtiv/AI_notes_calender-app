import SwiftUI
import Charts

struct ProductivityHeatmap: View {
    @Environment(AnalyticsEngine.self) private var analytics
    @State private var selectedHour: Int? = nil
    
    var body: some View {
        CardContainer(title: "Peak Hours") {
            Chart(0..<24, id: \.self) { hour in
                BarMark(
                    x: .value("Hour", hour),
                    y: .value("Tasks", analytics.metrics.peakProductivityHours.filter { $0 == hour }.count)
                )
                .foregroundStyle(selectedHour == hour ? .orange : .blue)
                .accessibilityLabel("Hour \(hour)")
                .accessibilityValue("\(countForHour(hour)) tasks")
                .annotation(position: .overlay) {
                    Text("\(hour)")
                        .font(.system(size: 8))
                        .rotationEffect(.degrees(-90))
                        .offset(y: 10)
                }
            }
            .chartYScale(domain: 0...analytics.metrics.peakProductivityHours.max() ?? 1)
            .chartXSelection(value: $selectedHour)
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .onTapGesture { location in
                            guard let plotFrame = proxy.plotFrame else { return }
                            let xPosition = location.x - plotFrame.origin.x
                            if let hour = proxy.value(atX: xPosition) {
                                selectedHour = hour
                            }
                        }
                }
            }
            .frame(height: 150)
            
            if let hour = selectedHour {
                Text("\(hour):00 - \(hour+1):00: \(countForHour(hour)) tasks")
                    .font(.caption)
                    .padding(8)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .transition(.opacity)
            }
        }
    }
    
    private func countForHour(_ hour: Int) -> Int {
        analytics.metrics.peakProductivityHours.filter { $0 == hour }.count
    }
}
