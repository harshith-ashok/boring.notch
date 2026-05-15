//
//  ShelfView.swift
//  boringNotch
//
//  Created by Alexander on 2025-09-24.
//

import SwiftUI

@MainActor
final class DeviceShelfStateManager: ObservableObject {
    static let shared = DeviceShelfStateManager()

    @Published private(set) var devices: [DeviceShelfEntry] = []

    private let stateFileURL = URL(fileURLWithPath: "/Users/harshith/.device_state.json")
    private var pollTimer: Timer?

    private init() {
        refreshState()
        startPolling()
    }

    deinit {
        pollTimer?.invalidate()
    }

    private func startPolling() {
        let timer = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refreshState()
            }
        }

        timer.tolerance = 0.2
        RunLoop.main.add(timer, forMode: .common)
        pollTimer = timer
    }

    func refreshState() {
        guard
            let data = try? Data(contentsOf: stateFileURL),
            let payload = try? JSONDecoder().decode(DeviceShelfPayload.self, from: data)
        else {
            devices = []
            return
        }

        let orderedNames = ["Main Light", "Ceiling Fan", "Accent Light"]
        devices = orderedNames.compactMap { name in
            guard let device = payload.devices[name] else { return nil }

            switch name {
            case "Main Light":
                return DeviceShelfEntry(
                    name: name,
                    icon: "lightbulb.fill",
                    isActive: device.status == 1,
                    accentColor: device.status == 1 ? .yellow : .gray,
                    statusText: device.status == 1 ? "On" : "Off",
                    detailText: nil
                )
            case "Ceiling Fan":
                return DeviceShelfEntry(
                    name: name,
                    icon: "fanblades.fill",
                    isActive: device.status == 1,
                    accentColor: device.status == 1 ? .cyan : .gray,
                    statusText: device.status == 1 ? "On" : "Off",
                    detailText: device.status == 1 ? "Speed \(device.value ?? 0)" : nil
                )
            case "Accent Light":
                return DeviceShelfEntry(
                    name: name,
                    icon: "lamp.floor.fill",
                    isActive: device.status == 1,
                    accentColor: device.status == 1 ? .green : .gray,
                    statusText: device.status == 1 ? "On" : "Off",
                    detailText: device.status == 1 ? device.color?.capitalized : nil
                )
            default:
                return nil
            }
        }
    }
}

private struct DeviceShelfPayload: Decodable {
    let devices: [String: DeviceShelfState]
}

private struct DeviceShelfState: Decodable {
    let status: Int
    let value: Int?
    let color: String?
}

struct DeviceShelfEntry: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let isActive: Bool
    let accentColor: Color
    let statusText: String
    let detailText: String?
}

struct ShelfView: View {
    @StateObject private var deviceState = DeviceShelfStateManager.shared

    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(Color.white.opacity(0.04))
            .overlay {
                shelfContent
                    .padding(18)
            }
    }

    @ViewBuilder
    private var shelfContent: some View {
        if deviceState.devices.isEmpty {
            VStack(spacing: 10) {
                Image(systemName: "switch.2")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white, .gray)
                    .font(.system(size: 28))

                Text("No device state available")
                    .foregroundStyle(.gray)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.medium)
            }
        } else {
            HStack(spacing: 12) {
                ForEach(deviceState.devices) { device in
                    DeviceShelfCard(device: device)
                }
            }
        }
    }
}

private struct DeviceShelfCard: View {
    let device: DeviceShelfEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: device.icon)
                    .foregroundStyle(device.accentColor)
                    .font(.system(size: 18, weight: .semibold))

                Text(device.name)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }

            Text(device.statusText)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(device.isActive ? .white : .gray)

            Text(device.detailText ?? " ")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.gray)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
        )
    }
}
