//
//  MoodColor.swift
//  MoodJo
//
//  Created by Edwin Salcedo on 12/30/25.
//

import SwiftUI

// MARK: - Emotion Position in Grid

enum EnergyLevel: Int, CaseIterable {
    case low = 0
    case medium = 1
    case high = 2
    
    var label: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
}

enum Valence: Int, CaseIterable {
    case negative = 0
    case neutral = 1
    case positive = 2
    
    var label: String {
        switch self {
        case .negative: return "Negative"
        case .neutral: return "Neutral"
        case .positive: return "Positive"
        }
    }
}

// MARK: - Color Hue Category

enum ColorHue: String, CaseIterable, Identifiable {
    case red = "Red"
    case orange = "Orange"
    case yellow = "Yellow"
    case green = "Green"
    case blue = "Blue"
    case purple = "Purple"
    
    var id: String { rawValue }
    
    var baseColor: Color {
        switch self {
        case .red: return Color(hue: 0.0, saturation: 0.75, brightness: 0.85)
        case .orange: return Color(hue: 0.08, saturation: 0.75, brightness: 0.95)
        case .yellow: return Color(hue: 0.15, saturation: 0.75, brightness: 0.95)
        case .green: return Color(hue: 0.35, saturation: 0.65, brightness: 0.75)
        case .blue: return Color(hue: 0.58, saturation: 0.65, brightness: 0.85)
        case .purple: return Color(hue: 0.75, saturation: 0.55, brightness: 0.75)
        }
    }
    
    var hueValue: Double {
        switch self {
        case .red: return 0.0
        case .orange: return 0.08
        case .yellow: return 0.15
        case .green: return 0.35
        case .blue: return 0.58
        case .purple: return 0.75
        }
    }
    
    /// Returns the 3x3 grid of emotions for this hue
    /// Grid is indexed as [energy][valence] where:
    /// - energy: 0 = low, 1 = medium, 2 = high
    /// - valence: 0 = negative, 1 = neutral, 2 = positive
    var emotionGrid: [[String]] {
        switch self {
        case .red:
            return [
                // Low energy
                ["Resentful", "Moody", "Warm"],
                // Medium energy
                ["Frustrated", "Intense", "Loving"],
                // High energy
                ["Enraged", "Passionate", "Excited"]
            ]
        case .orange:
            return [
                // Low energy
                ["Drained", "Mellow", "Cozy"],
                // Medium energy
                ["Restless", "Eager", "Cheerful"],
                // High energy
                ["Overwhelmed", "Energetic", "Thrilled"]
            ]
        case .yellow:
            return [
                // Low energy
                ["Uneasy", "Pensive", "Content"],
                // Medium energy
                ["Nervous", "Curious", "Optimistic"],
                // High energy
                ["Anxious", "Alert", "Joyful"]
            ]
        case .green:
            return [
                // Low energy
                ["Stagnant", "Resting", "Peaceful"],
                // Medium energy
                ["Envious", "Balanced", "Refreshed"],
                // High energy
                ["Jealous", "Determined", "Alive"]
            ]
        case .blue:
            return [
                // Low energy
                ["Depressed", "Calm", "Serene"],
                // Medium energy
                ["Melancholy", "Thoughtful", "Hopeful"],
                // High energy
                ["Distressed", "Focused", "Inspired"]
            ]
        case .purple:
            return [
                // Low energy
                ["Lonely", "Dreamy", "Mystical"],
                // Medium energy
                ["Conflicted", "Reflective", "Creative"],
                // High energy
                ["Grieving", "Intense", "Empowered"]
            ]
        }
    }
    
    /// Get emotion name at specific grid position
    func emotion(energy: EnergyLevel, valence: Valence) -> String {
        return emotionGrid[energy.rawValue][valence.rawValue]
    }
    
    /// Get color at specific grid position
    /// Brightness varies by valence: positive = brightest, negative = darkest
    /// Saturation varies slightly by energy level
    func color(energy: EnergyLevel, valence: Valence) -> Color {
        let baseBrightness: Double
        switch valence {
        case .positive: baseBrightness = 0.95
        case .neutral: baseBrightness = 0.75
        case .negative: baseBrightness = 0.55
        }
        
        let saturation: Double
        switch energy {
        case .high: saturation = 0.85
        case .medium: saturation = 0.70
        case .low: saturation = 0.55
        }
        
        return Color(hue: hueValue, saturation: saturation, brightness: baseBrightness)
    }
}

// MARK: - MoodColor

struct MoodColor: Equatable {
    let hue: ColorHue
    let energy: EnergyLevel
    let valence: Valence
    
    var color: Color {
        hue.color(energy: energy, valence: valence)
    }
    
    var name: String {
        hue.emotion(energy: energy, valence: valence)
    }
    
    // Convert to hex string for storage
    var hexString: String {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let rgb = Int(red * 255) << 16 | Int(green * 255) << 8 | Int(blue * 255)
        return String(format: "#%06x", rgb)
    }
    
    /// Encode full mood data for storage (hue, energy, valence)
    var encodedValue: String {
        "\(hue.rawValue)|\(energy.rawValue)|\(valence.rawValue)"
    }
    
    // Initialize from encoded value
    init?(encodedValue: String) {
        let components = encodedValue.split(separator: "|")
        guard components.count == 3,
              let hue = ColorHue(rawValue: String(components[0])),
              let energyRaw = Int(components[1]),
              let energy = EnergyLevel(rawValue: energyRaw),
              let valenceRaw = Int(components[2]),
              let valence = Valence(rawValue: valenceRaw) else {
            return nil
        }
        
        self.hue = hue
        self.energy = energy
        self.valence = valence
    }
    
    // Initialize from hex string (legacy support - finds closest match)
    init?(hexString: String) {
        var cleanedHex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanedHex = cleanedHex.replacingOccurrences(of: "#", with: "")
        
        guard cleanedHex.count == 6 else { return nil }
        
        var rgb: UInt64 = 0
        Scanner(string: cleanedHex).scanHexInt64(&rgb)
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        // Convert RGB to HSB to find closest match
        let uiColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        // Find closest hue
        let hueValue = Double(h)
        var closestHue = ColorHue.red
        var minDistance = Double.infinity
        
        for colorHue in ColorHue.allCases {
            let distance = min(abs(colorHue.hueValue - hueValue), 1 - abs(colorHue.hueValue - hueValue))
            if distance < minDistance {
                minDistance = distance
                closestHue = colorHue
            }
        }
        
        // Determine energy from saturation
        let energy: EnergyLevel
        if s < 0.6 {
            energy = .low
        } else if s < 0.75 {
            energy = .medium
        } else {
            energy = .high
        }
        
        // Determine valence from brightness
        let valence: Valence
        if b < 0.65 {
            valence = .negative
        } else if b < 0.85 {
            valence = .neutral
        } else {
            valence = .positive
        }
        
        self.hue = closestHue
        self.energy = energy
        self.valence = valence
    }
    
    // Initialize with specific values
    init(hue: ColorHue, energy: EnergyLevel, valence: Valence) {
        self.hue = hue
        self.energy = energy
        self.valence = valence
    }
    
    // MARK: - Legacy Support
    
    /// Get all moods as a flat array (for compatibility)
    static var allMoods: [MoodColor] {
        var moods: [MoodColor] = []
        for hue in ColorHue.allCases {
            for energy in EnergyLevel.allCases {
                for valence in Valence.allCases {
                    moods.append(MoodColor(hue: hue, energy: energy, valence: valence))
                }
            }
        }
        return moods
    }
    
    /// Legacy presets (maps to specific grid positions)
    static let presets: [MoodColor] = [
        MoodColor(hue: .yellow, energy: .high, valence: .positive),    // Happy/Joyful
        MoodColor(hue: .blue, energy: .low, valence: .positive),      // Calm/Serene
        MoodColor(hue: .red, energy: .high, valence: .negative),      // Angry/Enraged
        MoodColor(hue: .yellow, energy: .high, valence: .negative),   // Anxious
        MoodColor(hue: .green, energy: .low, valence: .positive),     // Peaceful
        MoodColor(hue: .orange, energy: .high, valence: .positive),   // Energetic/Thrilled
        MoodColor(hue: .red, energy: .medium, valence: .positive),    // Loving
        MoodColor(hue: .green, energy: .medium, valence: .neutral),   // Balanced/Neutral
        MoodColor(hue: .blue, energy: .low, valence: .negative)       // Sad/Depressed
    ]
}
