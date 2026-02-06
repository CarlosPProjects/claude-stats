import Foundation

// MARK: - API Response Models

struct OAuthUsageResponse: Codable {
    let fiveHour: UsageWindow?
    let sevenDay: UsageWindow?
    let sevenDayOauthApps: UsageWindow?
    let sevenDayOpus: UsageWindow?
    let sevenDaySonnet: UsageWindow?
    let sevenDayCowork: UsageWindow?
    let iguanaNecktie: UsageWindow?
    let extraUsage: ExtraUsage?
    
    enum CodingKeys: String, CodingKey {
        case fiveHour = "five_hour"
        case sevenDay = "seven_day"
        case sevenDayOauthApps = "seven_day_oauth_apps"
        case sevenDayOpus = "seven_day_opus"
        case sevenDaySonnet = "seven_day_sonnet"
        case sevenDayCowork = "seven_day_cowork"
        case iguanaNecktie = "iguana_necktie"
        case extraUsage = "extra_usage"
    }
}

struct UsageWindow: Codable {
    let utilization: Double
    let resetsAt: String
    
    enum CodingKeys: String, CodingKey {
        case utilization
        case resetsAt = "resets_at"
    }
}

struct ExtraUsage: Codable {
    let isEnabled: Bool
    let monthlyLimit: Int?
    let usedCredits: Double?
    let utilization: Double?
    
    enum CodingKeys: String, CodingKey {
        case isEnabled = "is_enabled"
        case monthlyLimit = "monthly_limit"
        case usedCredits = "used_credits"
        case utilization
    }
}

// MARK: - App Models

struct UsageData {
    let fiveHourPercent: Double
    let fiveHourResetAt: Date?
    let sevenDayPercent: Double
    let sevenDayResetAt: Date?
    let extraCreditsUsed: Double?
    let extraCreditsLimit: Int?
    
    var fiveHourResetFormatted: String {
        formatReset(fiveHourResetAt)
    }
    
    var sevenDayResetFormatted: String {
        formatReset(sevenDayResetAt)
    }
    
    private func formatReset(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }
        let now = Date()
        let diff = date.timeIntervalSince(now)
        
        if diff < 0 { return "Now" }
        
        let hours = Int(diff) / 3600
        let minutes = (Int(diff) % 3600) / 60
        
        if hours > 24 {
            let days = hours / 24
            let remainingHours = hours % 24
            return "\(days)d \(remainingHours)h"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    static func from(response: OAuthUsageResponse) -> UsageData {
        let fiveHour = response.fiveHour
        let sevenDay = response.sevenDay
        
        return UsageData(
            fiveHourPercent: fiveHour?.utilization ?? 0,
            fiveHourResetAt: parseDate(fiveHour?.resetsAt),
            sevenDayPercent: sevenDay?.utilization ?? 0,
            sevenDayResetAt: parseDate(sevenDay?.resetsAt),
            extraCreditsUsed: response.extraUsage?.usedCredits,
            extraCreditsLimit: response.extraUsage?.monthlyLimit
        )
    }
    
    private static func parseDate(_ string: String?) -> Date? {
        guard let string = string else { return nil }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: string) {
            return date
        }
        
        // Try without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: string)
    }
}
