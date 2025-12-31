//
//  JournalListView.swift
//  MoodJo
//
//  Created on 12/30/2024
//

import SwiftUI
import SwiftData

struct JournalListView: View {
    @Environment(JournalEntryManager.self) private var manager
    @State private var showingCreateSheet = false
    @State private var selectedEntry: JournalEntryEntity?
    
    var body: some View {
        NavigationStack {
            listContent
                .navigationTitle("MoodJo")
                .toolbar {
                    toolbarContent
                }
                .sheet(isPresented: $showingCreateSheet) {
                    CreateJournalView(onDismiss: {
                        showingCreateSheet = false
                    })
                }
                .sheet(item: $selectedEntry) { entry in
                    //JournalEntryDetailView(entry: entry)
                }
        }
    }
    
    @ViewBuilder
    private var listContent: some View {
        if manager.filteredEntries.isEmpty {
            emptyStateView
        } else {
            List {
                ForEach(manager.filteredEntries) { entry in
                    DateCellView(entry: entry)
                        .onTapGesture {
                            selectedEntry = entry
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                manager.deleteEntry(entry)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                manager.toggleFavorite(entry)
                            } label: {
                                Label(
                                    entry.isFavorite ? "Unfavorite" : "Favorite",
                                    systemImage: entry.isFavorite ? "star.slash" : "star"
                                )
                            }
                            .tint(.yellow)
                        }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            }
            .listStyle(.plain)
            .searchable(text: Binding(
                get: { manager.searchText },
                set: { manager.searchText = $0 }
            ), prompt: "Search entries")
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label(manager.showingFavoritesOnly ? "No Favorited Journal Entries" : "No Journal Entries", systemImage: "book.closed")
        } description: {
            Text(manager.showingFavoritesOnly ? "Favorite an entry by swiping on it" : "Start your journaling journey by creating your first entry")
        } actions: {
            if manager.showingFavoritesOnly {
                Button("Show Entries") {
                    manager.showingFavoritesOnly.toggle()
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Create Entry") {
                    showingCreateSheet = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                showingCreateSheet = true
            } label: {
                Label("New Entry", systemImage: "plus")
            }
        }
        
        ToolbarItem(placement: .navigationBarLeading) {
            Menu {
                Button {
                    manager.showingFavoritesOnly.toggle()
                } label: {
                    Label(
                        manager.showingFavoritesOnly ? "Show All" : "Show Favorites",
                        systemImage: "star"
                    )
                }
                
//                if !manager.allTags.isEmpty {
//                    Menu("Filter by Tag") {
//                        Button("All Tags") {
//                            manager.selectedTag = nil
//                        }
//                        
//                        ForEach(manager.allTags, id: \.self) { tag in
//                            Button(tag) {
//                                manager.selectedTag = tag
//                            }
//                        }
//                    }
//                }
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
            }
        }
    }
}

#Preview("Dark Mode") {
    JournalListView()
        .environment(JournalEntryManager(local: JournalEntryPersistence()))
        .preferredColorScheme(.dark)
}
#Preview("Light Mode") {
    JournalListView()
        .environment(JournalEntryManager(local: JournalEntryPersistence()))
        .preferredColorScheme(.light)
}
