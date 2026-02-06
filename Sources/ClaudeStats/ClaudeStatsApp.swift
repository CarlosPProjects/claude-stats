import SwiftUI

@main
struct ClaudeStatsApp: App {
    @StateObject private var service = ClaudeService()
    
    var body: some Scene {
        MenuBarExtra {
            ContentView(service: service)
                .frame(width: 280)
        } label: {
            MenuBarLabel(service: service)
        }
        .menuBarExtraStyle(.window)
    }
}

// MARK: - Menu Bar Label (Quick View)

struct MenuBarLabel: View {
    @ObservedObject var service: ClaudeService
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
            
            if let usage = service.usage {
                Text(quickStats)
                    .font(.system(.caption, design: .monospaced))
            } else if service.isLoading {
                Text("...")
                    .font(.caption)
            }
        }
    }
    
    private var iconName: String {
        guard let usage = service.usage else { return "chart.pie" }
        if usage.fiveHourPercent > 80 || usage.sevenDayPercent > 80 {
            return "chart.pie.fill"
        }
        return "chart.pie"
    }
    
    private var quickStats: String {
        guard let usage = service.usage else { return "" }
        let fiveH = Int(usage.fiveHourPercent)
        let sevenD = Int(usage.sevenDayPercent)
        return "\(fiveH)% | \(sevenD)%"
    }
}
