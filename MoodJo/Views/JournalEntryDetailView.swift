//
//  JournalEntryDetailView.swift
//  MoodJo
//
//  Created by Edwin Salcedo on 1/1/26.
//

import SwiftUI
import SwiftData

struct JournalEntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(JournalEntryManager.self) private var manager
    
    let entry: JournalEntryEntity
    
    @State private var isEditing = false
    @State private var title: String = ""
    @State private var text: String = ""
    @State private var selectedMoodColor: MoodColor?
    @State private var selectedImages: [UIImage] = []
    @State private var tags: [String] = []
    @State private var newTag: String = ""
    
    @State private var hasLoadedInitialData = false
    @State private var showingImageViewer = false
    @State private var selectedImageIndex = 0
    @State private var loadedImages: [UIImage] = []
    
    private var moodColor: MoodColor? {
        guard let moodString = entry.moodColor else { return nil }
        
        // Try new encoded format first, fallback to hex for legacy data
        if let mood = MoodColor(encodedValue: moodString) {
            return mood
        } else if let mood = MoodColor(hexString: moodString) {
            return mood
        }
        return nil
    }
    
    @Namespace private var imageNamespace
    
    @FocusState private var isAnyFieldFocused: Bool
    
    var canSave: Bool { !text.isEmpty }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                
                Group {
                    if isEditing {
                        editContent
                    } else {
                        displayContent
                    }
                }
                
                if showingImageViewer {
                    FullScreenImageView(
                        images: loadedImages,
                        selectedIndex: $selectedImageIndex,
                        isPresented: $showingImageViewer,
                        namespace: imageNamespace
                    )
                    .zIndex(1)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle(entry.timestamp.formatted(date: .abbreviated, time: .omitted))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !showingImageViewer {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                    if !isEditing {
                        ToolbarItem(placement: .primaryAction) {
                            Button("Edit") {
                                startEditing()
                            }
                        }
                    } else {
                        ToolbarItem(placement: .primaryAction) {
                            Button("Done") {
                                saveChanges()
                            }
                            .disabled(!canSave)
                        }
                    }
                }
            }
        }
        .onAppear {
            loadEntryData()
            loadImagesForViewer()
        }
        .interactiveDismissDisabled(showingImageViewer)
    }
    
    // MARK: - Display Mode
    
    private var displayContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                if let title = entry.title, !title.isEmpty {
                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                if !loadedImages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(loadedImages.enumerated()), id: \.offset) { index, image in
                                let isSelectedAndShowing = showingImageViewer && selectedImageIndex == index
                                
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .matchedGeometryEffect(
                                        id: "image-\(index)",
                                        in: imageNamespace,
                                    //isSource: !isSelectedAndShowing
                                    )
                                    .opacity(isSelectedAndShowing ? 0 : 1)
                                    .onTapGesture {
                                        selectedImageIndex = index
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                            showingImageViewer = true
                                        }
                                    }
                            }
                        }
                    }
                }
                
                Text(entry.text)
                    .font(.title3)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.ultraThinMaterial.opacity(0.7))
                    .cornerRadius(16)
                
                // Tags
                if !entry.tags.isEmpty {
                    FlowLayout(spacing: 8) {
                        ForEach(entry.tags, id: \.self) { tag in
                            Text(tag)
                                .foregroundStyle(.black)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.white.opacity(0.25))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                    }
                }
                
                // Metadata
                VStack(alignment: .leading, spacing: 4) {
                    Text("Created: \(entry.timestamp, style: .date) at \(entry.timestamp, style: .time)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if entry.lastModified != entry.timestamp {
                        Text("Last modified: \(entry.lastModified, style: .date) at \(entry.lastModified, style: .time)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Edit Mode
    
    private var editContent: some View {
        Form {
            Section("Title") {
                TextField("Give this day a title", text: $title)
                    .focused($isAnyFieldFocused)
            }
            
            Section("How are you feeling?") {
                MoodColorPickerView(selectedMoodColor: $selectedMoodColor)
            }
            
            Section("What's on your mind?") {
                TextEditor(text: $text)
                    .frame(minHeight: 150)
                    .focused($isAnyFieldFocused)
            }
            
            Section("Photos") {
                PhotoPicker(selectedImages: $selectedImages, maxImages: 5)
            }
            
            Section("Tags") {
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
                        .focused($isAnyFieldFocused)
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
        .scrollDismissesKeyboard(.immediately)
        .scrollContentBackground(.hidden)
    }
    
    @ViewBuilder
    private var backgroundGradient: some View {
        if let moodColor = moodColor {
            LinearGradient(
                colors: [
                    moodColor.color.opacity(0.45),
                    moodColor.color.opacity(0.65),
                    moodColor.color.opacity(0.75),
                    moodColor.color.opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(
                hasLoadedInitialData ? .easeInOut(duration: 0.5) : nil,
                value: selectedMoodColor?.name
            )
        } else {
            Color(.systemBackground)
                .ignoresSafeArea()
        }
    }
    
    // MARK: - Data Management
    
    private func loadEntryData() {
        title = entry.title ?? ""
        text = entry.text
        tags = entry.tags
        selectedImages = MediaManager.shared.loadImages(from: entry.imagePath)
        
        if let moodString = entry.moodColor {
            // Try new encoded format first, fallback to hex for legacy data
            if let mood = MoodColor(encodedValue: moodString) {
                selectedMoodColor = mood
            } else if let mood = MoodColor(hexString: moodString) {
                selectedMoodColor = mood
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            hasLoadedInitialData = true
        }
    }
    
    private func loadImagesForViewer() {
        loadedImages = MediaManager.shared.loadImages(from: entry.imagePath)
    }
    
    private func startEditing() {
        loadEntryData()
        isEditing = true
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
    
    private func saveChanges() {
        do {
            let oldPaths = entry.imagePath
            let newPaths = MediaManager.shared.saveImages(selectedImages)
            
            let pathsToDelete = oldPaths.filter { !newPaths.contains($0) }
            MediaManager.shared.deleteImages(filenames: pathsToDelete)
            
            try manager.updateEntry(
                entry,
                title: title.isEmpty ? nil : title,
                text: text,
                imagePath: newPaths,
                moodColor: selectedMoodColor?.encodedValue,
                tags: tags
            )
            
            loadImagesForViewer()
            isEditing = false
        } catch {
            print("Failed to save changes: \(error)")
        }
    }
}

#Preview("Dark Mode") {
    JournalEntryDetailView(entry: JournalEntryEntity.mockEntries[0])
        .environment(JournalEntryManager(local: JournalEntryPersistence()))
        .preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    JournalEntryDetailView(entry: JournalEntryEntity.mockEntries[0])
        .environment(JournalEntryManager(local: JournalEntryPersistence()))
        .preferredColorScheme(.light)
}
