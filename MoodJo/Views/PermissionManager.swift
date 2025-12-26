//
//  PermissionManager.swift
//  MoodJo
//
//  Created by Edwin Salcedo on 12/26/25.
//

import AVFoundation
import Photos
import UIKit
import Combine

class PermissionManager: ObservableObject {
    @Published var hasCameraPermission = false
    @Published var hasMicrophonePermission = false
    @Published var hasPhotoLibraryPermission = false
    
    init() {
        checkPermissions()
    }
    
    func checkPermissions() {
        checkCameraPermission()
        checkMicrophonePermission()
        checkPhotoLibraryPermission()
    }
    
    func requestCameraPermission() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            await MainActor.run {
                hasCameraPermission = granted
            }
        case .authorized:
            await MainActor.run {
                hasCameraPermission = true
            }
        default:
            await MainActor.run {
                hasCameraPermission = false
            }
        }
    }
    
    func requestMicrophonePermission() async {
        let status = AVAudioSession.sharedInstance().recordPermission
        
        switch status {
        case .undetermined:
            let granted = await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
            await MainActor.run {
                hasMicrophonePermission = granted
            }
        case .granted:
            await MainActor.run {
                hasMicrophonePermission = true
            }
        default:
            await MainActor.run {
                hasMicrophonePermission = false
            }
        }
    }
    
    func requestPhotoLibraryPermission() async {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .notDetermined:
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            await MainActor.run {
                hasPhotoLibraryPermission = newStatus == .authorized || newStatus == .limited
            }
        case .authorized, .limited:
            await MainActor.run {
                hasPhotoLibraryPermission = true
            }
        default:
            await MainActor.run {
                hasPhotoLibraryPermission = false
            }
        }
    }
    
    private func checkCameraPermission() {
        hasCameraPermission = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    private func checkMicrophonePermission() {
        hasMicrophonePermission = AVAudioSession.sharedInstance().recordPermission == .granted
    }
    
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        hasPhotoLibraryPermission = status == .authorized || status == .limited
    }
}
