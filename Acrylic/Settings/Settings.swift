//
//  Settings.swift
//  Assignment Tracker
//
//  Created by Ben K on 8/31/21.
//

import SwiftUI
import UIKit
import Introspect
import SwiftUIMailView

struct Settings: View {
    @AppStorage("prefixes", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var prefixes: [String] = []
    
    var body: some View {
        List {
            
            Section {
                
                SettingsGroup(name: "Preferences", systemName: "gear", background: .gray) {
                    PreferencesView()
                }
                
                SettingsGroup(name: "Hidden Assignments", systemName: "eye.slash", background: Color("indigo"), customContent: true) {
                    HiddenView()
                }
                
            } header: {
                Text("Settings")
            } footer: {
                Text("Tip: Hold down the user button on the main page to access settings quickly!")
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Section {
                
                SettingsGroup(name: "Canvas Settings", systemName: "network", background: .red) {
                    CanvasSettingsView()
                }
                
            }
            
            Section {
                
                SettingsGroup(name: "Contact", systemName: "at", background: .blue) {
                    Contact()
                }
                
                SettingsGroup(name: "Licenses", systemName: "text.justifyleft", background: Color("brown")) {
                    Licenses()
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    struct SettingsGroup<Content: View>: View {
        let name: String
        let image: Image
        let foreground: Color
        let background: Color
        
        let customContent: Bool
        let sheet: Content
        
        init(name: String, systemName: String, foreground: Color = .primary, background: Color, customContent: Bool = false, @ViewBuilder content: () -> Content) {
            self.name = name
            self.image = Image(systemName: systemName)
            self.foreground = foreground
            self.background = background
            
            self.customContent = customContent
            self.sheet = content()
        }
        
        @State private var showSheet = false
        
        var body: some View {
            Button {
                showSheet = true
            } label: {
                HStack {
                    image
                        .frame(width: 30, height: 30)
                        .foregroundColor(foreground)
                        .background(background)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                    Text(name)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.tertiaryLabel)
                }
                .foregroundColor(.primary)
                .padding(.vertical, 5)
            }
            .sheet(isPresented: $showSheet) {
                if customContent {
                    sheet
                } else {
                    GroupSheet(name: name, image: image, foreground: foreground, background: background) {
                        sheet
                    }
                }
            }
        }
        
        struct GroupSheet: View {
            @Environment(\.presentationMode) var presentationMode
            
            let name: String
            let image: Image
            let foreground: Color
            let background: Color
            let sheet: Content
            
            init(name: String, image: Image, foreground: Color, background: Color, @ViewBuilder content: () -> Content) {
                self.name = name
                self.image = image
                self.foreground = foreground
                self.background = background
                self.sheet = content()
            }
            
            var body: some View {
                NavigationView {
                    List {
                        sheet
                    }
                    .listStyle(.insetGrouped)
                    .navigationTitle(name)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Done") {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }
            }
        }
    }
    
    struct Contact: View {
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
    
    struct Licenses: View {
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
            Section {
                Link(destination: URL(string: "https://github.com/instructure/canvas-lms/blob/master/LICENSE")!) {
                    HStack {
                        Text("Canvas LMS")
                            .foregroundColor(.primary)
                        Spacer()
                        Text("License")
                            .font(.callout)
                    }
                }
                
                Section {
                    Link(destination: URL(string: "https://github.com/siteline/SwiftUI-Introspect/blob/master/LICENSE")!) {
                        HStack {
                            Text("Introspect for SwiftUI")
                                .foregroundColor(.primary)
                            Spacer()
                            Text("License")
                                .font(.callout)
                        }
                    }
                    Link(destination: URL(string: "https://github.com/onevcat/RandomColorSwift/blob/master/LICENSE")!) {
                        HStack {
                            Text("Random Color Swift")
                                .foregroundColor(.primary)
                            Spacer()
                            Text("License")
                                .font(.callout)
                        }
                    }
                    Link(destination: URL(string: "https://github.com/SvenTiigi/WhatsNewKit/blob/master/LICENSE")!) {
                        HStack {
                            Text("WhatsNewKit")
                                .foregroundColor(.primary)
                            Spacer()
                            Text("License")
                                .font(.callout)
                        }
                    }
                    Link(destination: URL(string: "https://github.com/globulus/swiftui-mail-view/blob/main/LICENSE")!) {
                        HStack {
                            Text("SwiftUIMailView")
                                .foregroundColor(.primary)
                            Spacer()
                            Text("License")
                                .font(.callout)
                        }
                    }
                }
            }
            .navigationTitle("Licenses")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    struct DevTools: View {
        @AppStorage("firstLaunch", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var showLanding: Bool = true
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
            Section {
                Button("Reset first launch") {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
