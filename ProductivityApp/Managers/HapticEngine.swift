import CoreHaptics

class HapticEngine {
    static let shared = HapticEngine()
    private var engine: CHHapticEngine?
    
    init() {
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic Engine Error: \(error)")
        }
    }
    
    func playDragHaptic() {
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
            ],
            relativeTime: 0
        )
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play haptic: \(error)")
        }
    }
}

struct HapticEngineKey: EnvironmentKey {
    static let defaultValue: HapticEngine = .shared
}

extension EnvironmentValues {
    var hapticEngine: HapticEngine {
        get { self[HapticEngineKey.self] }
        set { self[HapticEngineKey.self] = newValue }
    }
}
