//
//  MoodEntry.swift
//  MoodJo
//
//  Created by Edwin Salcedo on 12/26/25.
//

import Foundation
import UIKit

struct MoodEntry: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let mood: MoodType
    let journalText: String
    let imagePath: String? // Store image file path
    let audioPath: String? // Store audio file path
    
    enum MoodType: String, CaseIterable, Codable {
        case veryHappy = "Very Happy"
        case happy = "Happy"
        case neutral = "Neutral"
        case sad = "Sad"
        case verySad = "Very Sad"
        
        var emoji: String {
            switch self {
            case .veryHappy: return "😄"
            case .happy: return "😊"
            case .neutral: return "😐"
            case .sad: return "😢"
            case .verySad: return "😭"
            }
        }
        
        var color: String {
            switch self {
            case .veryHappy: return "green"
            case .happy: return "mint"
            case .neutral: return "yellow"
            case .sad: return "orange"
            case .verySad: return "red"
            }
        }
    }
}