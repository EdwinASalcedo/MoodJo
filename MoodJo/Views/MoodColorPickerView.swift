//
//  MoodColorPickerView.swift
//  MoodJo
//
//  Created by Edwin Salcedo on 12/30/25.
//

import SwiftUI

struct MoodColorPickerView: View {
    @Binding var selectedMoodColor: MoodColor?
    
    private let columns = [
        GridItem(.adaptive(minimum: 60), spacing: 16)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(MoodColor.presets, id: \.name) { moodColor in
                VStack(spacing: 8) {
                    Circle()
                        .fill(moodColor.color)
                        .frame(width: 50, height: 50)
                        .overlay {
                            Circle()
                                .stroke(
                                    isSelected(moodColor) ? Color.primary : Color.clear,
                                    lineWidth: 3
                                )
                        }
                        .overlay {
                            if isSelected(moodColor) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.white)
                                    .font(.title2)
                                    .shadow(radius: 2)
                            }
                        }
                        .onTapGesture {
                            toggleSelection(moodColor)
                        }
                    
                    Text(moodColor.name)
                        .font(.caption)
                        .foregroundStyle(isSelected(moodColor) ? .primary : .secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func isSelected(_ moodColor: MoodColor) -> Bool {
        guard let selected = selectedMoodColor else { return false }
        return selected.name == moodColor.name
    }
    
    private func toggleSelection(_ moodColor: MoodColor) {
        if isSelected(moodColor) {
            selectedMoodColor = nil
        } else {
            selectedMoodColor = moodColor
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedMood: MoodColor? = MoodColor.presets[0]
        
        var body: some View {
            Form {
                Section("Select Your Mood") {
                    MoodColorPickerView(selectedMoodColor: $selectedMood)
                }
            }
        }
    }
    
    return PreviewWrapper()
}
