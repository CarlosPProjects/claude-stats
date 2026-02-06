import SwiftUI

@main
struct ClaudeStatsApp: App {
    @StateObject private var service = ClaudeService()
    
    var body: some Scene {
        MenuBarExtra {
            ContentView(service: service)
                .frame(width: 280)
        } label: {
            Label("ClaudeStats", systemImage: statusIcon)
        }
        .menuBarExtraStyle(.window)
    }
    
    private var statusIcon: String {
        guard let usage = service.usage else { return "chart.pie" }
        if usage.percentUsed > 80 { return "chart.pie.fill" }
        return "chart.pie"
    }
}
