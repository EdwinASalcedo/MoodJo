//
//  View+HideKeyboard.swift
//  MoodJo
//
//  Created on 12/31/2024
//

import SwiftUI

extension View {
    /// Adds a tap gesture to dismiss the keyboard when tapping outside text fields
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
    
    /// Adds an invisible background that dismisses keyboard on tap
    /// This version doesn't interfere with other tap gestures
    func dismissKeyboardOnTap() -> some View {
        self.background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    hideKeyboard()
                }
        )
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}