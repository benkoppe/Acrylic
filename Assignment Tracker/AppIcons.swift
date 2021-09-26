//
//  AppIcons.swift
//  Assignment Tracker
//
//  Created by Ben K on 9/25/21.
//

import Foundation

let iconGroups = [defaults, socials, pride]

let defaults = IconGroup(name: nil, icons: ["AppIcon", "Inverted"])

let socials = IconGroup(name: "Social", icons: ["Influencer", "Is Typing...", "Musical", "Limit Reached", "Not Playing", "Misinformation"])

let pride = IconGroup(name: "Pride", icons: ["Rainbow", "Trans"])

struct IconGroup: Hashable {
    let name: String?
    let icons: [String]
}
