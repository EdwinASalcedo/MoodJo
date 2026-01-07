//
//  MoodColorPickerView.swift
//  MoodJo
//
//  Created by Edwin Salcedo on 12/30/25.
//

import SwiftUI

struct MoodColorPickerView: View {
    @Binding var selectedMoodColor: MoodColor?
    @State private var selectedHue: ColorHue = .red
    
    var body: some View {
        VStack(spacing: 16) {
            // Color hue tabs
            hueTabBar
            
            // Axis labels
            //axisLabels
            
            // 3x3 Emotion grid
            emotionGrid
        }
        .padding(.vertical, 8)
        .onAppear {
            // Set initial hue based on selected mood if exists
            if let mood = selectedMoodColor {
                selectedHue = mood.hue
            }
        }
    }
    
    // MARK: - Hue Tab Bar
    
    private var hueTabBar: some View {
        HStack(spacing: 16) {
            ForEach(ColorHue.allCases) { hue in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedHue = hue
                    }
                } label: {
                    Circle()
                        .fill(hue.baseColor)
                        .frame(width: selectedHue == hue ? 40 : 32, height: selectedHue == hue ? 40 : 32)
                        .overlay {
                            Circle()
                                .stroke(selectedHue == hue ? Color.primary : Color.clear, lineWidth: 3)
                        }
                        .shadow(color: selectedHue == hue ? hue.baseColor.opacity(0.5) : .clear, radius: 4)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
    
    // MARK: - Axis Labels
    
    private var axisLabels: some View {
        HStack {
            // Y-axis label (Energy)
            Text("Energy")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .rotationEffect(.degrees(-90))
                .fixedSize()
                .frame(width: 20)
            
            Spacer()
            
            // X-axis labels
            VStack {
                HStack {
                    Text("−")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("Valence")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("+")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.horizontal, 8)
    }
    
    // MARK: - Emotion Grid
    
    private var emotionGrid: some View {
        HStack(alignment: .center, spacing: 4) {
            // Energy level indicators on the left
//            VStack(spacing: 20) {
//                Text("▲")
//                    .font(.caption2)
//                    .foregroundStyle(.secondary)
//                Spacer()
//                Text("▼")
//                    .font(.caption2)
//                    .foregroundStyle(.secondary)
//            }
//            .frame(width: 16, height: 180)
            
            // Main grid
            VStack(spacing: 12) {
                // High energy row (top)
                gridRow(energy: .high)
                
                // Medium energy row (middle)
                gridRow(energy: .medium)
                
                // Low energy row (bottom)
                gridRow(energy: .low)
            }
        }
        .padding(.horizontal, 8)
    }
    
    private func gridRow(energy: EnergyLevel) -> some View {
        HStack(spacing: 12) {
            ForEach(Valence.allCases, id: \.rawValue) { valence in
                emotionCell(energy: energy, valence: valence)
            }
        }
    }
    
    private func emotionCell(energy: EnergyLevel, valence: Valence) -> some View {
        let mood = MoodColor(hue: selectedHue, energy: energy, valence: valence)
        let isSelected = selectedMoodColor?.hue == selectedHue &&
                        selectedMoodColor?.energy == energy &&
                        selectedMoodColor?.valence == valence
        
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                if isSelected {
                    selectedMoodColor = nil
                } else {
                    selectedMoodColor = mood
                }
            }
        } label: {
            VStack(spacing: 4) {
                Circle()
                    .fill(mood.color)
                    .frame(width: 50, height: 50)
                    .overlay {
                        Circle()
                            .stroke(isSelected ? Color.primary : Color.clear, lineWidth: 3)
                    }
                    .overlay {
                        if isSelected {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.white)
                                .font(.headline)
                                .shadow(radius: 2)
                        }
                    }
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                Text(mood.name)
                    .font(.system(size: 10))
                    .foregroundStyle(isSelected ? .primary : .secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedMood: MoodColor? = nil
        
        var body: some View {
            Form {
                Section("Select Your Mood") {
                    MoodColorPickerView(selectedMoodColor: $selectedMood)
                }
                
//                if let mood = selectedMood {
//                    Section("Selected") {
//                        HStack {
//                            Circle()
//                                .fill(mood.color)
//                                .frame(width: 30, height: 30)
//                            Text(mood.name)
//                            //Spacer()
////                            Text("\(mood.hue.rawValue)")
////                                .foregroundStyle(.secondary)
//                        }
//                    }
//                }
            }
        }
    }
    
    return PreviewWrapper()
}

#Preview("Dark Mode") {
    struct PreviewWrapper: View {
        @State private var selectedMood: MoodColor? = MoodColor(hue: .blue, energy: .medium, valence: .positive)
        
        var body: some View {
            Form {
                Section("Select Your Mood") {
                    MoodColorPickerView(selectedMoodColor: $selectedMood)
                }
            }
        }
    }
    
    return PreviewWrapper()
        .preferredColorScheme(.dark)
}
