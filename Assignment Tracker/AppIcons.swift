//
//  AppIcons.swift
//  Assignment Tracker
//
//  Created by Ben K on 9/25/21.
//

import Foundation

let iconGroups = [defaults, tints, socials, pride]

let defaults = IconGroup(name: nil, icons: ["AppIcon", "Inverted"])

let tints = IconGroup(name: "Tints", icons: ["Deep", "Wavy", "Snake", "Blood", "Royal"])

let socials = IconGroup(name: "Social", icons: ["Influencer", "Is Typing...", "Musical", "Limit Reached", "Not Playing", "Superspreader"])

let pride = IconGroup(name: "Spectral", icons: ["Baker", "Helms"])

struct IconGroup: Hashable {
    let name: String?
    let icons: [String]
}
