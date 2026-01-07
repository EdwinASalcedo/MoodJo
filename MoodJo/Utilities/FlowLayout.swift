//
//  FlowLayout.swift
//  MoodJo
//
//  Created by Edwin Salcedo on 1/6/26.
//
import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            let position = CGPoint(
                x: result.positions[index].x + bounds.origin.x,
                y: result.positions[index].y + bounds.origin.y
            )
            subview.place(at: position, proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentPosition: CGPoint = .zero
            var lineHeight: CGFloat = 0
            var maxX: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentPosition.x + size.width > maxWidth && currentPosition.x > 0 {
                    currentPosition.x = 0
                    currentPosition.y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(currentPosition)
                lineHeight = max(lineHeight, size.height)
                maxX = max(maxX, currentPosition.x + size.width)
                currentPosition.x += size.width + spacing
            }
            
            self.size = CGSize(width: maxX, height: currentPosition.y + lineHeight)
        }
    }
}
