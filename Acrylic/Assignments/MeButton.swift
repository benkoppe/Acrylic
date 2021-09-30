//
//  MeButton.swift
//  Acrylic
//
//  Created by Ben K on 9/28/21.
//

import SwiftUI

struct MeButton: View {
    @Binding var showingMeView: Bool
    
    @State private var preferences = false
    @State private var hidden = false
    
    var body: some View {
        Button(action: {
            showingMeView = true
        }) {
            Image(systemName: "person.crop.circle")
                .font(.body)
                .contextMenu {
                    Button {
                        preferences = true
                    } label: {
                        Image(systemName: "gear")
                        Text("Preferences")
                    }
                    Button {
                        hidden = true
                    } label: {
                        Image(systemName: "eye.slash")
                        Text("Hidden Assignments")
                    }
                }
                .padding([.vertical, .leading])
        }
        .sheet(isPresented: $preferences) {
            MeSheet(name: "Preferences") { PreferencesView() }
        }
        .sheet(isPresented: $hidden) {
            HiddenView()
        }
    }
    
    struct MeSheet<Content: View>: View {
        @Environment(\.presentationMode) var presentationMode
        
        let name: String
        let sheet: Content
        
        init(name: String, @ViewBuilder content: () -> Content) {
            self.name = name
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

struct MeButton_Previews: PreviewProvider {
    static var previews: some View {
        MeButton(showingMeView: .constant(true))
    }
}
