//
//  MoodJoApp.swift
//  MoodJo
//
//  Created by Edwin Salcedo on 12/26/25.
//

import SwiftUI

@main
struct MoodJoApp: App {
    
    var body: some Scene {
        WindowGroup {
            JournalListView()
        }
        .environment(JournalEntryManager(local: JournalEntryPersistence()))
    }
}
