//
//  JournalEntryManager.swift
//  MoodJo
//
//  Created on 12/30/2024
//

import SwiftUI
import SwiftData

@MainActor
@Observable
class JournalEntryManager {
    private let local: JournalEntryPersistence
    
    // Published state
    var entries: [JournalEntryEntity] = []
    var searchText: String = ""
    var showingFavoritesOnly: Bool = false
    var selectedTag: String?
    
    init(local: JournalEntryPersistence) {
        self.local = local
        fetchEntries()
    }
    
    // MARK: - Data Operations
    
    func fetchEntries() {
        do {
            entries = try local.fetchAllEntries()
        } catch {
            print("Failed to fetch entries: \(error)")
            entries = []
        }
    }
    
    func createEntry(
        for date: Date,
        title: String?,
        text: String?,
        imagePath: String? = nil,
        audioPath: String? = nil,
        moodColor: String?,
        tags: [String],
        isFavorite: Bool = false
    ) throws {
        // Check if entry already exists for this date
        if try local.entryExists(for: date) {
            throw JournalError.entryAlreadyExists
        }
        
        let entry = JournalEntryEntity(
            timestamp: date,
            lastModified: date,
            title: title,
            text: text,
            imagePath: imagePath,
            audioPath: audioPath,
            moodColor: moodColor,
            tags: tags,
            isFavorite: isFavorite
        )
        
        try local.addEntry(entry: entry)
        fetchEntries()
    }
    
    func updateEntry(
        _ entry: JournalEntryEntity,
        title: String?,
        text: String?,
        imagePath: String? = nil,
        audioPath: String? = nil,
        moodColor: String?,
        tags: [String]
    ) throws {
        entry.title = title
        entry.text = text
        entry.imagePath = imagePath
        entry.audioPath = audioPath
        entry.moodColor = moodColor
        entry.tags = tags
        
        try local.updateEntry(entry)
        fetchEntries()
    }
    
    func deleteEntry(_ entry: JournalEntryEntity) {
        do {
            try local.deleteEntry(entry)
            fetchEntries()
        } catch {
            print("Failed to delete entry: \(error)")
        }
    }
    
    func toggleFavorite(_ entry: JournalEntryEntity) {
        entry.isFavorite.toggle()
        do {
            try local.updateEntry(entry)
            fetchEntries()
        } catch {
            print("Failed to toggle favorite: \(error)")
        }
    }
    
    // MARK: - Query Operations
    
    func hasEntry(for date: Date) -> Bool {
        do {
            return try local.entryExists(for: date)
        } catch {
            print("Failed to check entry existence: \(error)")
            return false
        }
    }
    
    func entry(for date: Date) -> JournalEntryEntity? {
        do {
            return try local.fetchEntry(for: date)
        } catch {
            print("Failed to fetch entry for date: \(error)")
            return nil
        }
    }
    
    // MARK: - Filtering
    
    var filteredEntries: [JournalEntryEntity] {
        var result = entries
        
        // Filter by favorites if enabled
        if showingFavoritesOnly {
            result = result.filter { $0.isFavorite }
        }
        
        // Filter by selected tag if one is selected
        if let tag = selectedTag {
            result = result.filter { $0.tags.contains(tag) }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { entry in
                // Search in title
                if let title = entry.title, title.localizedCaseInsensitiveContains(searchText) {
                    return true
                }
                // Search in text content
                if let text = entry.text, text.localizedCaseInsensitiveContains(searchText) {
                    return true
                }
                // Search in tags
                if entry.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) }) {
                    return true
                }
                return false
            }
        }
        
        return result
    }
    
    // Get all unique tags from all entries
    var allTags: [String] {
        let tagSet = Set(entries.flatMap { $0.tags })
        return Array(tagSet).sorted()
    }
}

// MARK: - Custom Errors

enum JournalError: LocalizedError {
    case entryAlreadyExists
    
    var errorDescription: String? {
        switch self {
        case .entryAlreadyExists:
            return "An entry already exists for this date. Only one entry per day is allowed."
        }
    }
}
