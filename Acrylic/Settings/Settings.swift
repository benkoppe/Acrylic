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
                    ContactView()
                }
                
                SettingsGroup(name: "Licenses", systemName: "text.justifyleft", background: Color("brown")) {
                    LicensesView()
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
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
