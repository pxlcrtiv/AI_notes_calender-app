import Foundation
import NaturalLanguage

struct NaturalLanguageParser {
    static func parseTask(from string: String) -> (title: String, dueDate: Date?, recurrence: RecurrenceRule?) {
        let text = string.trimmingCharacters(in: .whitespaces)
        
        // Extract date components
        let dateRange = NSRange(location: 0, length: text.utf16.count)
        var detectedDate: Date? = nil
        var cleanedText = text
        
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
        detector?.enumerateMatches(in: text, options: [], range: dateRange) { match, _, _ in
            guard let match = match, let date = match.date else { return }
            detectedDate = date
            
            // Remove date phrases from original text
            if match.range.length > 0 {
                cleanedText = (text as NSString)
                    .replacingCharacters(in: match.range, with: "")
                    .trimmingCharacters(in: .whitespaces)
            }
        }
        
        // Extract priority keywords
        let priority = detectPriority(in: cleanedText)
        cleanedText = cleanedText
            .replacingOccurrences(of: "!!!", with: "")
            .replacingOccurrences(of: "!!", with: "")
            .replacingOccurrences(of: "!", with: "")
            .trimmingCharacters(in: .whitespaces)
        
        // Detect recurrence patterns
        let recurrence = detectRecurrence(in: cleanedText)
        cleanedText = removeRecurrenceMarkers(from: cleanedText)
        
        return (cleanedText, detectedDate, recurrence)
    }
    
    private static func detectPriority(in text: String) -> Int {
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        
        var priority = 1
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass) { tag, range in
            if tag == .adverb && text[range].lowercased() == "urgent" {
                priority = 3
            } else if tag == .adjective && text[range].lowercased() == "important" {
                priority = 2
            }
            return true
        }
        return priority
    }
    
    private static func detectRecurrence(in text: String) -> RecurrenceRule? {
        let patterns = [
            ("every day", .daily),
            ("daily", .daily),
            ("weekly", .weekly),
            ("monthly", .monthly),
            ("every week", .weekly),
            ("every month", .monthly),
            ("every year", .yearly)
        ]
        
        for (pattern, rule) in patterns {
            if text.lowercased().contains(pattern) {
                return RecurrenceRule(frequency: rule)
            }
        }
        return nil
    }
    
    private static func removeRecurrenceMarkers(from text: String) -> String {
        let patterns = ["every day", "daily", "weekly", "monthly", "every week", "every month", "every year"]
        return patterns.reduce(text.lowercased()) { $0.replacingOccurrences(of: $1, with: "") }
            .trimmingCharacters(in: .whitespaces)
    }
}

struct RecurrenceRule: Codable {
    enum Frequency: String, Codable {
        case daily, weekly, monthly, yearly
    }
    let frequency: Frequency
    var endDate: Date? = nil
}
