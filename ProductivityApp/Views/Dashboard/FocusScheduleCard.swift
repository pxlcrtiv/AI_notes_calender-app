import SwiftUI

struct FocusScheduleCard: View {
    @Environment(AnalyticsEngine.self) private var analytics
    
    var body: some View {
        CardContainer(title: "Recommended Focus Times") {
            VStack(alignment: .leading) {
                ForEach(analytics.recommendFocusSessions().prefix(3)) { session in
                    HStack {
                        Text(session.timeRange)
                            .font(.headline)
                        Spacer()
                        Text(String(format: "%.0f%%", session.intensity * 100))
                            .foregroundColor(intensityColor(session.intensity))
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    private func intensityColor(_ intensity: Double) -> Color {
        switch intensity {
        case 0.8...1.0: return .green
        case 0.5..<0.8: return .orange
        default: return .red
        }
    }
}
