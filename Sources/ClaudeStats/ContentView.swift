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
                // Session Usage
                UsageBar(
                    title: "Session",
                    value: usage.percentUsed / 100,
                    subtitle: "Resets in \(usage.resetTimeFormatted)"
                )
                
                // Daily Limit (if available)
                if let daily = usage.dailyPercentUsed {
                    UsageBar(
                        title: "Daily",
                        value: daily / 100,
                        subtitle: "Resets at midnight"
                    )
                }
                
                Divider()
                
                // Stats
                HStack {
                    VStack(alignment: .leading) {
                        Text("Model")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(usage.model ?? "claude-3.5-sonnet")
                            .font(.caption)
                    }
                    Spacer()
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
            
            // Actions
            HStack {
                Button(action: { Task { await service.fetchUsage() } }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(service.isLoading)
                
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
        .task {
            await service.fetchUsage()
        }
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

#Preview {
    ContentView(service: ClaudeService())
        .frame(width: 280)
}
