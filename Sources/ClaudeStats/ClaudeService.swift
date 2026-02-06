import Foundation
import SwiftUI

@MainActor
class ClaudeService: ObservableObject {
    @Published var usage: UsageData?
    @Published var error: String?
    @Published var isLoading = false
    
    private let apiURL = URL(string: "https://api.anthropic.com/api/oauth/usage")!
    
    func fetchUsage() async {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        // Try to get token from keychain first, then from file
        guard let token = getToken() else {
            error = "No auth token found.\nRun 'claude' CLI to authenticate."
            return
        }
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("oauth-2025-04-20", forHTTPHeaderField: "anthropic-beta")
        request.timeoutInterval = 10
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                error = "Invalid response"
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                error = "API error: \(httpResponse.statusCode)"
                return
            }
            
            let decoded = try JSONDecoder().decode(OAuthUsageResponse.self, from: data)
            usage = UsageData.from(response: decoded)
            
        } catch let decodingError as DecodingError {
            error = "Parse error: \(decodingError.localizedDescription)"
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    // MARK: - Token Retrieval
    
    private func getToken() -> String? {
        // Try credential files first (no keychain prompt!)
        if let token = getTokenFromFile() {
            return token
        }
        
        // Fallback to keychain (will prompt for password)
        return getTokenFromKeychain()
    }
    
    private func getTokenFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "Claude Code-credentials",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        // Parse the JSON to extract accessToken
        guard let jsonData = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let oauth = json["claudeAiOauth"] as? [String: Any],
              let accessToken = oauth["accessToken"] as? String else {
            return nil
        }
        
        return accessToken
    }
    
    private func getTokenFromFile() -> String? {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
        
        let credPaths = [
            "\(homeDir)/.claude.json",  // Claude CLI stores here
            "\(homeDir)/.claude/credentials.json",
            "\(homeDir)/.config/claude/credentials.json"
        ]
        
        for path in credPaths {
            guard FileManager.default.fileExists(atPath: path),
                  let data = FileManager.default.contents(atPath: path),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let oauth = json["claudeAiOauth"] as? [String: Any],
                  let accessToken = oauth["accessToken"] as? String else {
                continue
            }
            return accessToken
        }
        
        return nil
    }
}
