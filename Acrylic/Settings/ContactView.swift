//
//  ContactView.swift
//  Acrylic
//
//  Created by Ben K on 9/30/21.
//

import SwiftUI
import SwiftUIMailView

struct ContactView: View {
    @State private var contactMailData = ComposeMailData(subject: "[Acrylic \(Bundle.main.releaseVersionNumber ?? "VERSION NOT FOUND") (\(Bundle.main.buildVersionNumber ?? "BUILD NOT FOUND"))]", recipients: ["Koppe.Development@gmail.com"], message: "", attachments: [])
    @State private var showContactMail = false
    
    var body: some View {
        Section {
            Button {
                showContactMail = true
            } label: {
                HStack {
                    Text("Email")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.tertiaryLabel)
                }
                .foregroundColor(.primary)
            }
            .sheet(isPresented: $showContactMail) {
                MailView(data: $contactMailData) { result in
                    print(result)
                }
            }
            
            Button {
                let screenName =  "ben.koppe"
                
                let appURL = URL(string:  "instagram://user?username=\(screenName)")
                let webURL = URL(string:  "https://instagram.com/\(screenName)")
                
                if let appURL = appURL, UIApplication.shared.canOpenURL(appURL) {
                    UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
                } else {
                    if let webURL = webURL {
                        UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
                    } else {
                        print("Could not open instagram.")
                    }
                }
            } label: {
                HStack {
                    Text("Instagram")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.tertiaryLabel)
                }
                .foregroundColor(.primary)
            }
        } header: {
            Text("Contact")
        }
    }
}

struct ContactView_Previews: PreviewProvider {
    static var previews: some View {
        ContactView()
    }
}
