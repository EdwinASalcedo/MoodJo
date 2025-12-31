//
//  JournalEntryEntity.swift
//  MoodJo
//
//  Created by Edwin Salcedo on 12/30/25.
//

import Foundation
import SwiftData

@Model
final class JournalEntryEntity {
    var timestamp: Date
    var lastModified: Date
    var title: String?
    var text: String?
    var imagePath: String?
    var audioPath: String?
    var moodColor: String?
    var tags: [String]
    var isFavorite: Bool
    
    init(
        timestamp: Date = Date(),
        lastModified: Date,
        title: String? = nil,
        text: String? = nil,
        imagePath: String? = nil,
        audioPath: String? = nil,
        moodColor: String? = nil,
        tags: [String] = [],
        isFavorite: Bool = false
    ) {
        self.timestamp = timestamp
        self.lastModified = timestamp
        self.title = title
        self.text = text
        self.imagePath = imagePath
        self.audioPath = audioPath
        self.moodColor = moodColor
        self.tags = tags
        self.isFavorite = isFavorite
    }
    
    // Helper computed properties to get only date and no time
    var dateOnly: Date {
        Calendar.current.startOfDay(for: timestamp)
    }
    
    // Update lastModified when entry is edited
    func markAsModified() {
        self.lastModified = Date()
    }
}
