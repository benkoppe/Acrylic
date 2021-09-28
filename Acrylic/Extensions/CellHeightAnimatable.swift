//
//  CellHeightAnimatable.swift
//  Acrylic
//
//  Created by Ben K on 9/28/21.
//

import SwiftUI
import UIKit

struct AnimatingCellHeight: AnimatableModifier {
    var height: CGFloat = 0

    var animatableData: CGFloat {
        get { height }
        set { height = newValue }
    }

    func body(content: Content) -> some View {
        content.frame(height: height)
    }
}
