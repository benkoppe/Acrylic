//
//  AcrylicWhatsNew.swift
//  Acrylic
//
//  Created by Ben K on 9/28/21.
//

import SwiftUI
import WhatsNewKit
import WhatsNewKitSwiftUI

struct AcrylicWhatsNew: View {
    let whatsNew: WhatsNew = WhatsNew(title: "What's new in Version 1.2", items: [
        WhatsNew.Item(title: "New App Icons", subtitle: "13 new app icons! Check them out!", image: UIImage(systemName: "square.grid.3x3")),
        WhatsNew.Item(title: "New Animations", subtitle: "App now looks a little cleaner and sleeker.", image: UIImage(systemName: "sparkles")),
        WhatsNew.Item(title: "Widget Features", subtitle: "The widget now has a built-in option to display late assignments.", image: UIImage(systemName: "square")),
        WhatsNew.Item(title: "Bug Fixes", subtitle: "The widget should now appear in iOS 14. (maybe?)", image: UIImage(systemName: "ant")),
        WhatsNew.Item(title: "Rewording", subtitle: "A few sentences have been better clarified.", image: UIImage(systemName: "a.magnify"))
    ])
    var whatsNewConfiguration: WhatsNewViewController.Configuration {
        var config = WhatsNewViewController.Configuration(theme: .darkBlue)
        config.itemsView.animation = .slideRight
        config.itemsView.contentMode = .top
        config.completionButton = .init(stringLiteral: "Check it out!")
        config.backgroundColor = .secondarySystemBackground
        config.titleView.insets.top -= 40
        config.titleView.insets.bottom -= 20
        config.completionButton.insets.bottom -= 30
        return config
    }
    
    var body: some View {
        WhatsNewView(whatsNew: self.whatsNew, configuration: whatsNewConfiguration)
    }
}

struct AcrylicWhatsNew_Previews: PreviewProvider {
    static var previews: some View {
        AcrylicWhatsNew()
    }
}
