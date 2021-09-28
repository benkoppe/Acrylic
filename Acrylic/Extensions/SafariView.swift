//
//  SafariView.swift
//  Acrylic
//
//  Created by Ben K on 9/28/21.
//

/*USAGE
 
 SafariView(url:URL(string: self.urlString)!)
 
 */

import SwiftUI
import UIKit
import SafariServices

struct SafariView: UIViewControllerRepresentable {

    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {

    }

}
