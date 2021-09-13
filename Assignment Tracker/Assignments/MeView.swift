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
    
    @AppStorage("pfp", store: UserDefaults(suiteName: "group.com.benk.assytrack")) var pfp: Data?
    
    @State private var toggle = false
    
    var pfpImage: Image {
        let defaults = UserDefaults.init(suiteName: "group.com.benk.assytrack")
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
                    Spacer().frame(height: 30)
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
                    pfpImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .clipShape(
                            Circle()
                        )
                        .offset(y: 20)
                        .shadow(color: .black, radius: 15)
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
