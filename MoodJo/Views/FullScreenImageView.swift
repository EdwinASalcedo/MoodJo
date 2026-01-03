//
//  FullScreenImageView.swift
//  MoodJo
//
//  Created on 1/3/26.
//

import SwiftUI

struct FullScreenImageView: View {
    let images: [UIImage]
    @Binding var selectedIndex: Int
    @Binding var isPresented: Bool
    let namespace: Namespace.ID
    
    @State private var dragOffset: CGSize = .zero
    @State private var backgroundOpacity: Double = 0.0
    @State private var imageScale: CGFloat = 1.0
    @State private var horizontalDragOffset: CGFloat = 0
    
    private let dismissThreshold: CGFloat = 100
    private let swipeThreshold: CGFloat = 50
    
    var body: some View {
        ZStack {
            // Darkened background
            Color.black
                .opacity(0.9 * backgroundOpacity)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissViewer()
                }
            
            // Current image with matched geometry
            Image(uiImage: images[selectedIndex])
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .matchedGeometryEffect(
                    id: "image-\(selectedIndex)",
                    in: namespace,
                    isSource: true
                )
                .scaleEffect(imageScale)
                .offset(x: horizontalDragOffset, y: dragOffset.height)
                .gesture(combinedGesture)
            
            // Page indicator for multiple images
            if images.count > 1 {
                VStack {
                    Spacer()
                    Text("\(selectedIndex + 1) / \(images.count)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial.opacity(0.5))
                        .clipShape(Capsule())
                        .padding(.bottom, 50)
                        .opacity(backgroundOpacity)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.25)) {
                backgroundOpacity = 1.0
            }
        }        
    }
    
    private var combinedGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let horizontal = value.translation.width
                let vertical = value.translation.height
                
                // Determine if this is primarily a horizontal or vertical drag
                if abs(horizontal) > abs(vertical) && images.count > 1 {
                    // Horizontal swipe for navigation
                    horizontalDragOffset = horizontal
                    dragOffset = .zero
                    let progress = min(abs(horizontal) / 200, 1.0)
                    imageScale = 1.0 - (progress * 0.2)
                } else {
                    // Vertical drag for dismiss
                    dragOffset = CGSize(width: 0, height: vertical)
                    horizontalDragOffset = 0
                    
                    let progress = min(abs(vertical) / 300, 1.0)
                    imageScale = 1.0 - (progress * 0.2)
                    backgroundOpacity = 1.0 - progress
                }
            }
            .onEnded { value in
                let horizontal = value.translation.width
                let vertical = value.translation.height
                
                if abs(horizontal) > abs(vertical) && images.count > 1 {
                    // Handle horizontal swipe
                    if horizontal < -swipeThreshold && selectedIndex < images.count - 1 {
                        // Swipe left - next image
                        withAnimation(.spring(response: 0.3, dampingFraction: 1)) {
                            selectedIndex += 1
                            horizontalDragOffset = 0
                            imageScale = 1.0
                        }
                    } else if horizontal > swipeThreshold && selectedIndex > 0 {
                        // Swipe right - previous image
                        withAnimation(.spring(response: 0.3, dampingFraction: 1)) {
                            selectedIndex -= 1
                            horizontalDragOffset = 0
                            imageScale = 1.0
                        }
                    } else {
                        // Snap back
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            horizontalDragOffset = 0
                            imageScale = 1.0
                        }
                    }
                } else {
                    // Handle vertical dismiss
                    if abs(vertical) > dismissThreshold || abs(value.predictedEndTranslation.height) > 200 {
                        dismissViewer()
                    } else {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            dragOffset = .zero
                            imageScale = 1.0
                            backgroundOpacity = 1.0
                        }
                    }
                }
            }
    }
    
    private func dismissViewer() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            isPresented = false
            dragOffset = .zero
            imageScale = 1.0
            backgroundOpacity = 0.0
            horizontalDragOffset = 0
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var isPresented = false
        @State private var selectedIndex = 0
        @Namespace private var namespace
        
        var body: some View {
            ZStack {
                Color.gray.opacity(0.3).ignoresSafeArea()
                
                VStack {
                    if !isPresented {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 200)
                            .matchedGeometryEffect(
                                id: "image-0",
                                in: namespace,
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                    isPresented = true
                                }
                            }
                    } else {
                        Color.clear
                            .frame(width: 150, height: 200)
                    }
                }
                
                if isPresented {
                    FullScreenImageView(
                        images: [UIImage(systemName: "photo")!, UIImage(systemName: "photo")!],
                        selectedIndex: $selectedIndex,
                        isPresented: $isPresented,                        
                        namespace: namespace
                    )
                }
            }
        }
    }
    
    return PreviewWrapper()
}
