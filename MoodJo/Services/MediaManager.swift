//
//  MediaManager.swift
//  MoodJo
//
//  Created by Edwin Salcedo on 1/2/26.
//

import UIKit
import SwiftUI

@MainActor
final class MediaManager {
    static let shared = MediaManager()
    
    private init() {
        createDirectoriesIfNeeded()
    }
    
    // MARK: - Directory Setup
    
    private var imagesDirectory: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("JournalImages", isDirectory: true)
    }
    
    private var audioDirectory: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("JournalAudio", isDirectory: true)
    }
    
    private func createDirectoriesIfNeeded() {
        try? FileManager.default.createDirectory(
            at: imagesDirectory,
            withIntermediateDirectories: true
        )
        try? FileManager.default.createDirectory(
            at: audioDirectory,
            withIntermediateDirectories: true
        )
    }
    
    // MARK: - Image Operations
    
    /// Save multiple images and return array of file paths
    func saveImages(_ images: [UIImage]) -> [String] {
        var filePaths: [String] = []
        
        for image in images {
            if let path = saveImage(image) {
                filePaths.append(path)
            }
        }
        
        return filePaths
    }
    
    /// Save a single image and return its file path
    func saveImage(_ image: UIImage) -> String? {
        // Generate unique filename
        let filename = UUID().uuidString + ".jpg"
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        
        // Compress and save image
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        do {
            try imageData.write(to: fileURL)
            return filename // Store relative path
        } catch {
            print("Failed to save image: \(error)")
            return nil
        }
    }
    
    /// Load a single image from file path
    func loadImage(from filename: String) -> UIImage? {
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        guard let imageData = try? Data(contentsOf: fileURL) else {
            return nil
        }
        return UIImage(data: imageData)
    }
    
    /// Load multiple images from file paths
    func loadImages(from filenames: [String]) -> [UIImage] {
        filenames.compactMap { loadImage(from: $0) }
    }
    
    /// Delete a single image
    func deleteImage(filename: String) {
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    /// Delete multiple images
    func deleteImages(filenames: [String]) {
        filenames.forEach { deleteImage(filename: $0) }
    }
    
    // MARK: - Audio Operations (Placeholder for Phase 3)
    
    func saveAudio(_ data: Data) -> String? {
        let filename = UUID().uuidString + ".m4a"
        let fileURL = audioDirectory.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            return filename
        } catch {
            print("Failed to save audio: \(error)")
            return nil
        }
    }
    
    func loadAudio(from filename: String) -> Data? {
        let fileURL = audioDirectory.appendingPathComponent(filename)
        return try? Data(contentsOf: fileURL)
    }
    
    func deleteAudio(filename: String) {
        let fileURL = audioDirectory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    // MARK: - Cleanup
    
    /// Remove all orphaned media files (files not referenced by any entry)
    func cleanupOrphanedFiles(referencedImagePaths: [String], referencedAudioPaths: [String]) {
        // Clean images
        if let imageFiles = try? FileManager.default.contentsOfDirectory(
            at: imagesDirectory,
            includingPropertiesForKeys: nil
        ) {
            for fileURL in imageFiles {
                let filename = fileURL.lastPathComponent
                if !referencedImagePaths.contains(filename) {
                    try? FileManager.default.removeItem(at: fileURL)
                }
            }
        }
        
        // Clean audio
        if let audioFiles = try? FileManager.default.contentsOfDirectory(
            at: audioDirectory,
            includingPropertiesForKeys: nil
        ) {
            for fileURL in audioFiles {
                let filename = fileURL.lastPathComponent
                if !referencedAudioPaths.contains(filename) {
                    try? FileManager.default.removeItem(at: fileURL)
                }
            }
        }
    }
}
