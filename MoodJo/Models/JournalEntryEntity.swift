//
//  JournalEntryEntity.swift
//  MoodJo
//
//  Created by Edwin Salcedo on 12/30/25.
//

import SwiftUI
import SwiftData

@Model
final class JournalEntryEntity {
    var timestamp: Date
    var lastModified: Date
    var title: String?
    var text: String
    var imagePath: [String]
    var audioPath: String?
    var moodColor: String?
    var tags: [String]
    var isFavorite: Bool
    
    init(
        timestamp: Date = Date(),
        lastModified: Date? = nil,
        title: String? = nil,
        text: String = "",
        imagePath: [String] = [],
        audioPath: String? = nil,
        moodColor: String? = nil,
        tags: [String] = [],
        isFavorite: Bool = false
    ) {
        self.timestamp = timestamp
        self.lastModified = lastModified ?? timestamp
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
    
    static var mockEntries: [JournalEntryEntity] {
        [
            JournalEntryEntity(
                timestamp: Calendar.current.date(byAdding: .day, value: 0, to: Date())!,
                lastModified: Date(),
                title: "Amazing Day at the Beach",
                text: "Spent the entire day at the beach with friends. The weather was perfect and we played volleyball until sunset. Feeling grateful for these moments!",
                moodColor: MoodColor(color: .yellow, name: "Happy").hexString,
                tags: ["beach", "friends", "grateful"],
                isFavorite: true
            ),
            
            JournalEntryEntity(
                timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                lastModified: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                title: "Productive Work Day",
                text: "Finally finished that project I've been working on for weeks. Team meeting went well and got great feedback from my manager.",
                moodColor: MoodColor(color: .green, name: "Peaceful").hexString,
                tags: ["work", "productive", "achievement"]
            ),
            
            JournalEntryEntity(
                timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
                lastModified: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
                title: nil,
                text: "Feeling a bit anxious about the upcoming presentation. Need to practice more and get everything organized.",
                moodColor: MoodColor(color: .purple, name: "Anxious").hexString,
                tags: ["work", "anxious"]
            ),
            
            JournalEntryEntity(
                timestamp: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
                lastModified: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
                title: "Morning Run",
                text: "Woke up early and went for a 5-mile run. The sunrise was beautiful and I feel so energized for the day ahead!",
                moodColor: MoodColor(color: .orange, name: "Energetic").hexString,
                tags: ["exercise", "morning", "health"],
                isFavorite: true
            ),
            
            JournalEntryEntity(
                timestamp: Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
                lastModified: Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
                title: "Quiet Sunday",
                text: "Just a calm, relaxing day at home. Read a book, did some cooking, and enjoyed the peace and quiet.",
                moodColor: MoodColor(color: .blue, name: "Calm").hexString,
                tags: ["relaxing", "home", "self-care"]
            ),
            
            JournalEntryEntity(
                timestamp: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
                lastModified: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
                title: "Date Night",
                text: "Had the most wonderful dinner date tonight. Tried that new Italian restaurant downtown and it was amazing. Feeling so loved!",
                moodColor: MoodColor(color: .pink, name: "Loved").hexString,
                tags: ["date", "love", "food"],
                isFavorite: true
            ),
            
            JournalEntryEntity(
                timestamp: Calendar.current.date(byAdding: .day, value: -6, to: Date())!,
                lastModified: Calendar.current.date(byAdding: .day, value: -6, to: Date())!,
                title: "Rough Day",
                text: "Everything seemed to go wrong today. Spilled coffee, missed the bus, and had a headache all afternoon. Tomorrow will be better.",
                moodColor: MoodColor(color: .indigo, name: "Sad").hexString,
                tags: ["difficult", "frustrated"]
            ),
            
            JournalEntryEntity(
                timestamp: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
                lastModified: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
                title: "Family Gathering",
                text: "Big family BBQ today. It was chaotic but fun seeing everyone together. Kids were running around and there was so much laughter.",
                moodColor: MoodColor(color: .yellow, name: "Happy").hexString,
                tags: ["family", "celebration", "kids"]
            ),
            
            JournalEntryEntity(
                timestamp: Calendar.current.date(byAdding: .day, value: -8, to: Date())!,
                lastModified: Calendar.current.date(byAdding: .day, value: -8, to: Date())!,
                title: nil,
                text: "Not much happened today. Just went through the motions. Feeling kind of neutral about everything.",
                moodColor: MoodColor(color: .gray, name: "Neutral").hexString,
                tags: ["ordinary"]
            ),
            
            JournalEntryEntity(
                timestamp: Calendar.current.date(byAdding: .day, value: -9, to: Date())!,
                lastModified: Calendar.current.date(byAdding: .day, value: -9, to: Date())!,
                title: "Started New Hobby",
                text: "Signed up for pottery classes! First session was tonight and I absolutely loved it. Can't wait to go back next week.",
                moodColor: MoodColor(color: .orange, name: "Energetic").hexString,
                tags: ["hobby", "creative", "pottery"],
                isFavorite: true
            )
        ]
    }
}
