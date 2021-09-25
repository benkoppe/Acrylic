//
//  Gradient-Foreground.swift
//  Assignment Tracker
//
//  Created by Ben K on 9/13/21.
//

import SwiftUI

extension View {
    public func gradientForeground(colors: [Color], startPoint: UnitPoint = .topLeading, endPoint: UnitPoint = .bottomTrailing) -> some View {
        self.overlay(LinearGradient(gradient: .init(colors: colors),
                                    startPoint: startPoint,
                                    endPoint: endPoint))
            .mask(self)
    }
}
