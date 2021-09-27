//
//  ColorsEqual.swift
//  Assignment Tracker
//
//  Created by Ben K on 9/24/21.
//

import SwiftUI

func colorsEqual(_ lhs: Color, _ rhs: Color) -> Bool {
    func roundrgba(_ color: Color) -> (red: Double, blue: Double, green: Double, alpha: Double) {
        let rgba = UIColor(color).rgba
        return (round(rgba.red * 1000), round(rgba.blue * 1000), round(rgba.green * 1000), round(rgba.alpha * 1000))
    }
    
    if roundrgba(lhs) == roundrgba(rhs) {
        return true
    } else {
        return false
    }
}
