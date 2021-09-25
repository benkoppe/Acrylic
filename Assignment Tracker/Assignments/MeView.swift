//
//  MeView.swift
//  Assignment Tracker
//
//  Created by Ben K on 9/9/21.
//

import SwiftUI
import UIKit

struct MeView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showingSettings = false
    
    @AppStorage("pfp", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var pfp: Data?
    @AppStorage("prefixes", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var prefixes: [String] = []
    
    @State private var toggle = false
    
    var pfpImage: Image {
        let defaults = UserDefaults.init(suiteName: "group.com.benk.acrylic")
        if let data = defaults?.data(forKey: "pfp"), let image = UIImage(data: data) {
            return Image(uiImage: image)
        } else {
            return Image(systemName: "person.crop.circle")
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if showingSettings {
                    Settings()
                } else {
                    CourseList()
                }
            }
            .onChange(of: pfp) { _ in toggle.toggle() }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Button(action: {
                        if !prefixes.isEmpty, let url = URL(string: "https://\(prefixes[0]).instructure.com/") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        pfpImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .clipShape(
                                Circle()
                            )
                            .offset(y: 20)
                            .shadow(color: .black, radius: 15)
                            .foregroundColor(.primary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if showingSettings {
                        Button(action: {
                            withAnimation { showingSettings = false }
                        }) {
                            Image(systemName: "list.bullet.rectangle")
                        }
                    } else {
                        Button(action: {
                            withAnimation { showingSettings = true }
                        }) {
                            Image(systemName: "gearshape")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.down")
                    }
                }
            }
        }
    }
}

struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        MeView()
    }
}
