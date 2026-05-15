import Foundation
import SwiftUI

@MainActor
final class VoiceAssistantStateManager: ObservableObject {
    static let shared = VoiceAssistantStateManager()

    @Published private(set) var isListening = false

    private let stateFileURL: URL
    private var pollTimer: Timer?

    private init() {
        stateFileURL = URL(fileURLWithPath: "/Users/harshith/.status.json")

        refreshState()
        startPolling()
    }

    deinit {
        pollTimer?.invalidate()
    }

    private func startPolling() {
        let timer = Timer(
            timeInterval: 0.2,
            repeats: true
        ) { [weak self] _ in
            self?.refreshState()
        }

        timer.tolerance = 0.1
        RunLoop.main.add(timer, forMode: .common)
        pollTimer = timer
    }

    private func refreshState() {
        guard let data = try? Data(contentsOf: stateFileURL) else {
            updateListeningState(false)
            return
        }

        guard let payload = try? JSONDecoder().decode(VoiceAssistantStatePayload.self, from: data) else {
            updateListeningState(false)
            return
        }

        updateListeningState(payload.isListening)
    }

    private func updateListeningState(_ newValue: Bool) {
        guard isListening != newValue else { return }

        withAnimation(.smooth(duration: 0.2)) {
            isListening = newValue
        }
    }
}

private struct VoiceAssistantStatePayload: Decodable {
    let isListening: Bool

    enum CodingKeys: String, CodingKey {
        case isListening = "is_listening"
    }
}
