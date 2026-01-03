//
//  PhotoPicker.swift
//  MoodJo
//
//  Created by Edwin Salcedo on 1/2/26.
//

import SwiftUI
import PhotosUI

struct PhotoPicker: View {
    @Binding var selectedImages: [UIImage]
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showingCamera = false
    @State private var showingActionSheet = false
    @State private var showingPhotoPicker = false
    
    let maxImages: Int
    
    init(selectedImages: Binding<[UIImage]>, maxImages: Int = 10) {
        self._selectedImages = selectedImages
        self.maxImages = maxImages
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Display selected images
            if !selectedImages.isEmpty {
                imageGrid
            }
            
            // Add photos button
            if selectedImages.count < maxImages {
                addPhotoButton
            }
        }
    }
    
    // MARK: - Image Grid
    
    private var imageGrid: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Remove button
                        Button {
                            removeImage(at: index)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.white)
                                .background(Circle().fill(Color.black.opacity(0.6)))
                                .font(.title3)
                        }
                        .padding(4)
                    }
                }
            }
        }
    }
    
    // MARK: - Add Photo Button
    
    private var addPhotoButton: some View {
        Button {
            showingActionSheet = true
        } label: {
            HStack {
                Image(systemName: "photo.on.rectangle.angled")
                Text("Add Photos")
                Spacer()
                Text("\(selectedImages.count)/\(maxImages)")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .confirmationDialog("Add Photo", isPresented: $showingActionSheet) {
            Button {
                showingPhotoPicker = true
            } label: {
                Label("Choose from Library", systemImage: "photo.on.rectangle")
            }
            
            Button {
                showingCamera = true
            } label: {
                Label("Take Photo", systemImage: "camera")
            }
            
            Button("Cancel", role: .cancel) {}
        }
        .photosPicker(
            isPresented: $showingPhotoPicker,
            selection: $selectedItems,
            maxSelectionCount: maxImages - selectedImages.count,
            matching: .images
        )
        .onChange(of: selectedItems) { _, newItems in
            Task {
                await loadSelectedPhotos(from: newItems)
            }
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraPicker(image: $selectedImages, isPresented: $showingCamera)
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadSelectedPhotos(from items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    selectedImages.append(image)
                }
            }
        }
        
        // Clear selected items after loading
        await MainActor.run {
            selectedItems = []
        }
    }
    
    private func removeImage(at index: Int) {
        selectedImages.remove(at: index)
    }
}

// MARK: - Camera Picker

struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: [UIImage]
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        
        init(_ parent: CameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.image.append(image)
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var images: [UIImage] = []
        
        var body: some View {
            Form {
                Section("Photos") {
                    PhotoPicker(selectedImages: $images, maxImages: 5)
                }
            }
        }
    }
    
    return PreviewWrapper()
}
