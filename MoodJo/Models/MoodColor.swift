//
//  MoodColor.swift
//  MoodJo
//
//  Created by Edwin Salcedo on 12/30/25.
//
import SwiftUI

struct MoodColor: Equatable {
    let color: Color
    let name: String
    
    // Convert Color to hex string for storage
    var hexString: String {
        // SwiftUI Color doesn't have direct hex conversion, so we use a UIColor bridge
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let rgb = Int(red * 255) << 16 | Int(green * 255) << 8 | Int(blue * 255)
        return String(format: "#%06x", rgb)
    }
    
    // Initialize from hex string (for loading from SwiftData)
    init?(hexString: String) {
        var cleanedHex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanedHex = cleanedHex.replacingOccurrences(of: "#", with: "")
        
        guard cleanedHex.count == 6 else { return nil }
        
        var rgb: UInt64 = 0
        Scanner(string: cleanedHex).scanHexInt64(&rgb)
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.color = Color(red: red, green: green, blue: blue)
        self.name = "Custom" // Could enhance this to detect preset colors
    }
    
    // Initialize with color and name
    init(color: Color, name: String) {
        self.color = color
        self.name = name
    }
    
    // Preset mood colors for users to choose from
    static let presets: [MoodColor] = [
        MoodColor(color: .yellow, name: "Happy"),
        MoodColor(color: .blue, name: "Calm"),
        MoodColor(color: .red, name: "Angry"),
        MoodColor(color: .purple, name: "Anxious"),
        MoodColor(color: .green, name: "Peaceful"),
        MoodColor(color: .orange, name: "Energetic"),
        MoodColor(color: .pink, name: "Loved"),
        MoodColor(color: .gray, name: "Neutral"),
        MoodColor(color: .indigo, name: "Sad")
    ]
}
