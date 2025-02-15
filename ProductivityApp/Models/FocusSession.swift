import Foundation

struct FocusSession: Identifiable {
    let id = UUID()
    let startHour: Int
    let endHour: Int
    let intensity: Double
    
    var timeRange: String {
        "\(startHour):00 - \(endHour):00"
    }
}
