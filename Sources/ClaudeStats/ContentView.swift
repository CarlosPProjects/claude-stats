import SwiftUI

struct ContentView: View {
    @ObservedObject var service: ClaudeService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundStyle(.purple)
                Text("Claude Usage")
                    .font(.headline)
                Spacer()
                if service.isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                }
            }
            
            if let usage = service.usage {
                // 5-Hour Session
                UsageBar(
                    title: "5-Hour Session",
                    value: usage.fiveHourPercent / 100,
                    subtitle: "Resets in \(usage.fiveHourResetFormatted)"
                )
                
                // 7-Day Usage
                UsageBar(
                    title: "7-Day Usage", 
                    value: usage.sevenDayPercent / 100,
                    subtitle: "Resets in \(usage.sevenDayResetFormatted)"
                )
                
                // Extra Credits (if enabled)
                if let used = usage.extraCreditsUsed, let limit = usage.extraCreditsLimit {
                    Divider()
                    HStack {
                        Image(systemName: "creditcard")
                            .foregroundStyle(.green)
                        Text("Credits")
                            .font(.subheadline)
                        Spacer()
                        Text("$\(String(format: "%.2f", used)) / $\(limit)")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
                
            } else if let error = service.error {
                // Error state
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title2)
                        .foregroundStyle(.orange)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                
            } else {
                // Empty state
                VStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("Click refresh to load")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            
            Divider()
            
            // Actions + Last Updated
            HStack {
                Button(action: { Task { await service.fetchUsage() } }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(service.isLoading)
                
                Spacer()
                
                if let lastUpdated = service.lastUpdated {
                    Text(lastUpdated, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                
                Spacer()
                
                Button(action: { NSApplication.shared.terminate(nil) }) {
                    Text("Quit")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .controlSize(.small)
                .keyboardShortcut("q")
            }
        }
        .padding()
    }
}

// MARK: - Usage Bar Component

struct UsageBar: View {
    let title: String
    let value: Double
    let subtitle: String
    
    private var color: Color {
        if value > 0.9 { return .red }
        if value > 0.7 { return .orange }
        if value > 0.5 { return .yellow }
        return .blue
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.subheadline)
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(color)
            }
            
            ProgressView(value: min(value, 1.0))
                .tint(color)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// Preview requires Xcode
#Preview {
    ContentView(service: ClaudeService())
        .frame(width: 280)
}
