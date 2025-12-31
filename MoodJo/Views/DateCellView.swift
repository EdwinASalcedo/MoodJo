//
//  DateCellView.swift
//  MoodJo
//
//  Created by Edwin Salcedo on 12/29/25.
//

import SwiftUI

struct DateCellView: View {
    
    let entry: JournalEntryEntity
    var imageName: String? = Constants.randomImage
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(entry.timestamp, style: .date)
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    if entry.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(.caption)
                    }
                }
                
                if let title = entry.title, !title.isEmpty {
                    Text(title)
                        .font(.title3)
                        .bold()
                        .lineLimit(1)
                } else {
                    Text("No title")
                        .font(.title3)
                        .italic()
                }
                
                if let text = entry.text, !text.isEmpty {
                    Text(text)
                        .font(.callout)
                        .lineLimit(1)
                }
                
                if !entry.tags.isEmpty {
                    tagList
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if let imageName {
                ImageLoaderView(urlString: imageName)
                    .frame(width: 55, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Spacer()
                Rectangle()
                    .frame(width: 55, height: 70)
                    .opacity(0)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(strokeColor, lineWidth: 3)
        )
    }
    
    private var tagList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(entry.tags, id: \.self) { tag in
                    Text(tag)
                        .foregroundStyle(.black)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial.opacity(0.2))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.black, lineWidth: 1)
                        )
                }
            }
        }
        .padding(.top, 4)
    }
    
    private var backgroundGradient: LinearGradient {
        if let hexString = entry.moodColor, let moodColor = MoodColor(hexString: hexString) {
            return LinearGradient(
                colors: [
                    moodColor.color.opacity(0.65),
                    moodColor.color.opacity(0.95)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                colors: [
                    Color(.systemGray6),
                    Color(.systemGray6)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    // Computed property for stroke color
    private var strokeColor: Color {
        if let hexString = entry.moodColor,
            let moodColor = MoodColor(hexString: hexString) {
            return moodColor.color.opacity(0.9)
        } else {
            return Color.gray.opacity(0.2)
        }
    }
}

