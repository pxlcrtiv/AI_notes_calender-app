import SwiftData

@Model
class Event {
    var title: String
    var date: Date
    var location: String
    var notes: String
    
    init(title: String, date: Date = .now, location: String = "", notes: String = "") {
        self.title = title
        self.date = date
        self.location = location
        self.notes = notes
    }
}
