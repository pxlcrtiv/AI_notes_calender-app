import Foundation

struct ProductivityMetrics {
    var tasksCompleted: Int
    var averageCompletionTime: TimeInterval
    var peakProductivityHours: [Int]
    var commonTaskCategories: [String]
    var weeklyTrend: [Double]
    var trendAnnotations: [String]
}

struct TrendAnalysis {
    var weeklyCompletionRate: Double
    var taskBacklogCount: Int
    var estimatedTimeSavings: TimeInterval
}
