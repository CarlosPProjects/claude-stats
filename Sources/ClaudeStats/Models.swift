import Foundation

// MARK: - API Response Models

struct OAuthUsageResponse: Codable {
    let type: String
    let sessionUsage: SessionUsage?
    let dailyUsage: DailyUsage?
    
    enum CodingKeys: String, CodingKey {
        case type
        case sessionUsage = "session_usage"
        case dailyUsage = "daily_usage"
    }
}

struct SessionUsage: Codable {
    let requests: Int
    let requestsLimit: Int
    let tokens: Int
    let tokensLimit: Int
    let resetAt: String
    
    enum CodingKeys: String, CodingKey {
        case requests
        case requestsLimit = "requests_limit"
        case tokens
        case tokensLimit = "tokens_limit"
        case resetAt = "reset_at"
    }
}

struct DailyUsage: Codable {
    let requests: Int
    let requestsLimit: Int
    let tokens: Int
    let tokensLimit: Int
    
    enum CodingKeys: String, CodingKey {
        case requests
        case requestsLimit = "requests_limit"
        case tokens
        case tokensLimit = "tokens_limit"
    }
}

// MARK: - App Models

struct UsageData {
    let percentUsed: Double
    let dailyPercentUsed: Double?
    let resetAt: Date?
    let model: String?
    
    var resetTimeFormatted: String {
        guard let resetAt = resetAt else { return "Unknown" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: resetAt, relativeTo: Date())
    }
    
    static func from(response: OAuthUsageResponse) -> UsageData {
        let sessionPercent: Double
        if let session = response.sessionUsage {
            // Use token-based calculation (more accurate)
            if session.tokensLimit > 0 {
                sessionPercent = Double(session.tokens) / Double(session.tokensLimit) * 100
            } else if session.requestsLimit > 0 {
                sessionPercent = Double(session.requests) / Double(session.requestsLimit) * 100
            } else {
                sessionPercent = 0
            }
        } else {
            sessionPercent = 0
        }
        
        let dailyPercent: Double?
        if let daily = response.dailyUsage {
            if daily.tokensLimit > 0 {
                dailyPercent = Double(daily.tokens) / Double(daily.tokensLimit) * 100
            } else if daily.requestsLimit > 0 {
                dailyPercent = Double(daily.requests) / Double(daily.requestsLimit) * 100
            } else {
                dailyPercent = nil
            }
        } else {
            dailyPercent = nil
        }
        
        var resetDate: Date?
        if let resetString = response.sessionUsage?.resetAt {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            resetDate = formatter.date(from: resetString)
            
            // Try without fractional seconds if that fails
            if resetDate == nil {
                formatter.formatOptions = [.withInternetDateTime]
                resetDate = formatter.date(from: resetString)
            }
        }
        
        return UsageData(
            percentUsed: sessionPercent,
            dailyPercentUsed: dailyPercent,
            resetAt: resetDate,
            model: nil
        )
    }
}
