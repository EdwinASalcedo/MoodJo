//
//  AudioRecorderView.swift
//  MoodJo
//
//  Created by Edwin Salcedo on 12/26/25.
//

import SwiftUI
import AVFoundation
import Combine

class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var isRecording = false
    @Published var recordingTime: TimeInterval = 0
    @Published var audioFileURL: URL?
    
    private var audioRecorder: AVAudioRecorder?
    private var recordingTimer: Timer?
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }
    
    func startRecording() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            isRecording = true
            recordingTime = 0
            audioFileURL = audioFilename
            
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                self.recordingTime = self.audioRecorder?.currentTime ?? 0
            }
        } catch {
            print("Recording failed: \(error)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        recordingTimer?.invalidate()
        recordingTimer = nil
        isRecording = false
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
}

struct AudioRecorderView: View {
    @StateObject private var audioRecorder = AudioRecorder()
    @Binding var audioURL: URL?
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: audioRecorder.isRecording ? "mic.fill" : "mic")
                    .foregroundColor(audioRecorder.isRecording ? .red : .gray)
                    .font(.title2)
                
                Text(audioRecorder.isRecording ? "Recording..." : "Tap to record")
                    .font(.headline)
                
                if audioRecorder.isRecording {
                    Text(String(format: "%.1fs", audioRecorder.recordingTime))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Button(action: {
                if audioRecorder.isRecording {
                    audioRecorder.stopRecording()
                    audioURL = audioRecorder.audioFileURL
                } else {
                    audioRecorder.startRecording()
                }
            }) {
                Circle()
                    .fill(audioRecorder.isRecording ? Color.red : Color.blue)
                    .frame(width: 80, height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: audioRecorder.isRecording ? 8 : 40)
                            .fill(Color.white)
                            .frame(width: audioRecorder.isRecording ? 30 : 70, 
                                   height: audioRecorder.isRecording ? 30 : 70)
                    )
            }
            .scaleEffect(audioRecorder.isRecording ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: audioRecorder.isRecording)
            
            if audioURL != nil {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Audio recorded successfully")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}
