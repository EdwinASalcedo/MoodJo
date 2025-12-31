//
//  JournalEntryPersistence.swift
//  MoodJo
//
//  Created by Edwin Salcedo on 12/30/25.
//

import SwiftUI
import SwiftData

@MainActor
struct JournalEntryPersistence {
    private let container: ModelContainer
    private var mainContext: ModelContext {
        container.mainContext
    }
    
    init() {
        self.container = try! ModelContainer(for: JournalEntryEntity.self)
    }
    
    func addEntry(entry: JournalEntryEntity) throws {
        mainContext.insert(entry)
        try mainContext.save()
    }
    
    func fetchAllEntries() throws -> [JournalEntryEntity] {
        let descriptor = FetchDescriptor<JournalEntryEntity>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return try mainContext.fetch(descriptor)
    }
    
    func fetchEntry(for date: Date) throws -> JournalEntryEntity? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return nil
        }
        
        let descriptor = FetchDescriptor<JournalEntryEntity>(
            predicate: #Predicate { entry in
                entry.timestamp >= startOfDay && entry.timestamp < endOfDay
            }
        )
        return try mainContext.fetch(descriptor).first
    }
    
    func entryExists(for date: Date) throws -> Bool {
        return try fetchEntry(for: date) != nil
    }
    
    func updateEntry(_ entry: JournalEntryEntity) throws {
        entry.markAsModified()
        try mainContext.save()
    }
    
    func deleteEntry(_ entry: JournalEntryEntity) throws {
        mainContext.delete(entry)
        try mainContext.save()
    }
}
