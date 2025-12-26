//
//  ContentView.swift
//  MoodJo
//
//  Created by Edwin Salcedo on 12/26/25.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedMood: MoodEntry.MoodType = .neutral
    @State private var journalText: String = ""
    @State private var selectedImage: UIImage?
    @State private var audioURL: URL?
    
    // Image picker states
    @State private var showingPhotoLibrary = false
    @State private var showingCamera = false
    @State private var showingImageOptions = false
    
    // Audio recorder state
    @State private var showingAudioRecorder = false
    
    // Keyboard handling
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerView
                    moodSelectionView
                    mediaButtonsView
                    journalEntryView
                    saveButtonView
                }
                .padding()
            }
            .navigationTitle("Mood Journal")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingPhotoLibrary) {
                PhotoPickerView(selectedImage: $selectedImage)
            }
            .sheet(isPresented: $showingCamera) {
                CameraView(selectedImage: $selectedImage)
            }
            .sheet(isPresented: $showingAudioRecorder) {
                AudioRecorderView(audioURL: $audioURL)
            }
            .confirmationDialog("Choose Image Source", isPresented: $showingImageOptions) {
                Button("Camera") {
                    showingCamera = true
                }
                Button("Photo Library") {
                    showingPhotoLibrary = true
                }
                if selectedImage != nil {
                    Button("Remove Photo", role: .destructive) {
                        selectedImage = nil
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("How are you feeling today?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text(Date.now.formatted(date: .complete, time: .omitted))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Mood Selection
    private var moodSelectionView: some View {
        VStack(spacing: 16) {
            Text("Select Your Mood")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                ForEach(MoodEntry.MoodType.allCases, id: \.self) { mood in
                    Button(action: {
                        selectedMood = mood
                        // Add haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }) {
                        VStack(spacing: 8) {
                            Text(mood.emoji)
                                .font(.system(size: 40))
                            
                            Text(mood.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedMood == mood ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedMood == mood ? Color.blue : Color.clear, lineWidth: 2)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Media Buttons
    private var mediaButtonsView: some View {
        HStack(spacing: 16) {
            // Photo Button
            Button(action: {
                showingImageOptions = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: selectedImage != nil ? "photo.fill" : "camera")
                        .foregroundColor(selectedImage != nil ? .blue : .gray)
                }
                .frame(width: 40, height: 40)
                .padding(.vertical, 12)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Audio Button
            Button(action: {
                showingAudioRecorder = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: audioURL != nil ? "mic.fill" : "mic")
                        .foregroundColor(audioURL != nil ? .blue : .gray)
                }
                .frame(width: 40, height: 40)
                .padding(.vertical, 12)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Journal Entry
    private var journalEntryView: some View {
        VStack(spacing: 12) {
            Text("Journal Entry")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("What's on your mind? Share your thoughts, experiences, or anything you'd like to remember about today...", 
                     text: $journalText, axis: .vertical)
                .focused($isTextFieldFocused)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(6, reservesSpace: true)
        }
    }
    // MARK: - Save Button
    private var saveButtonView: some View {
        Button(action: saveMoodEntry) {
            HStack {
                Image(systemName: "square.and.arrow.down")
                Text("Save Entry")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .opacity(journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
    }
    
    // MARK: - Save Function
    private func saveMoodEntry() {
        // Here you would typically save to Core Data, SwiftData, or your preferred storage
        // For now, we'll just provide haptic feedback and reset the form
        
        let entry = MoodEntry(
            date: Date.now,
            mood: selectedMood,
            journalText: journalText,
            imagePath: nil, // You would save the image and store the path here
            audioPath: audioURL?.path
        )
        
        // Success haptic feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        // Reset the form
        resetForm()
        
        // In a real app, you might show a success message or navigate somewhere
        print("Saved mood entry: \(entry)")
    }
    
    private func resetForm() {
        selectedMood = .neutral
        journalText = ""
        selectedImage = nil
        audioURL = nil
        isTextFieldFocused = false
    }
}

#Preview {
    ContentView()
}
