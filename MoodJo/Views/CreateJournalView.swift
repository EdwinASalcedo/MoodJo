//
//  CreateJournalView.swift
//  MoodJo
//
//  Created by Edwin Salcedo on 12/30/25.
//


//
//  CreateJournalView.swift
//  MoodJo
//
//  Created on 12/30/2024
//

import SwiftUI
import SwiftData

struct CreateJournalView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(JournalEntryManager.self) private var manager
    
    let onDismiss: () -> Void
    
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false
    @State private var title: String = ""
    @State private var text: String = ""
    @State private var selectedMoodColor: MoodColor?
    @State private var selectedImages: [UIImage] = []
    @State private var tags: [String] = []
    @State private var newTag: String = ""
    @State private var errorMessage: String?
    @State private var showingError = false
    
    var canSave: Bool {
        // Text entry SHOULD be there
        !text.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                    .onTapGesture {
                        hideKeyboard()
                    }
                
                Form {
                    Section {
                        Button {
                            showingDatePicker.toggle()
                        } label: {
                            Text(selectedDate, style: .date)
                        }
                        
                        if showingDatePicker {
                            DatePicker(
                                "Select Date",
                                selection: $selectedDate,
                                in: ...Date(),
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                        }
                    } header: {
                        Text("When")
                    } footer: {
                        Text("Only one entry per day is allowed")
                    }
                    
                    Section("Title (Optional)") {
                        TextField("Give this day a title", text: $title)
                    }
                    
                    Section("Mood (Optional)") {
                        MoodColorPickerView(selectedMoodColor: $selectedMoodColor)
                    }
                    
                    Section("What's on your mind?") {
                        TextEditor(text: $text)
                            .frame(minHeight: 150)
                    }
                    
                    Section("Add Photos") {
                        PhotoPicker(selectedImages: $selectedImages, maxImages: 5)
                    }
                    
                    Section("Tags (Optional)") {
                        ForEach(tags, id: \.self) { tag in
                            HStack {
                                Text(tag)
                                Spacer()
                                Button(role: .destructive) {
                                    removeTag(tag)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                        
                        HStack {
                            TextField("Add tag", text: $newTag)
                                .onSubmit {
                                    addTag()
                                }
                            
                            Button("Add") {
                                addTag()
                            }
                            .disabled(newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntry()
                    }
                    .disabled(!canSave)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .animation(.easeInOut(duration: 0.5), value: selectedMoodColor)
    }
    
    private var gradientColors: [Color] {
        if let moodColor = selectedMoodColor {
            return [
                moodColor.color.opacity(0.15),
                moodColor.color.opacity(0.65),
                Color(.systemGray6)
            ]
        } else {
            return [
                Color(.systemGray6),
                Color(.systemGray6)
            ]
        }
    }
    
    // MARK: - Tag Management
    
    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTag.isEmpty, !tags.contains(trimmedTag) else { return }
        
        tags.append(trimmedTag)
        newTag = ""
    }
    
    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
    
    // MARK: - Actions
    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
    
    private func saveEntry() {
        do {
            // Save images and get file paths
            let imagePaths = MediaManager.shared.saveImages(selectedImages)
            
            try manager.createEntry(
                for: selectedDate,
                title: title.isEmpty ? nil : title,
                text: text,
                imagePath: imagePaths,
                moodColor: selectedMoodColor?.hexString,
                tags: tags
            )
            onDismiss()
        } catch let error as JournalError {
            errorMessage = error.errorDescription
            showingError = true
        } catch {
            errorMessage = "Failed to save entry: \(error.localizedDescription)"
            showingError = true
        }
    }
}

#Preview("Light Mode") {
    CreateJournalView(onDismiss: {})
        .environment(JournalEntryManager(local: JournalEntryPersistence()))
}

#Preview("Dark Mode") {
    CreateJournalView(onDismiss: {})
        .environment(JournalEntryManager(local: JournalEntryPersistence()))
        .preferredColorScheme(.dark)
}
