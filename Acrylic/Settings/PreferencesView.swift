//
//  PreferencesView.swift
//  Acrylic
//
//  Created by Ben K on 9/30/21.
//

import SwiftUI

struct PreferencesView: View {
    @AppStorage("showLate", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var showLate: Bool = true
    @AppStorage("icon", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var currentIcon: String = "AppIcon"
    @AppStorage("defaultSort", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var defaultSortMode: SortMode = .date
    @AppStorage("hideScrollBar", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var hideScrollBar: Bool = true
    @AppStorage("exactHeaders", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var exactHeaders: Bool = false
    @State private var showingAppIcon = false
    
    
    var body: some View {
        Section {
            Button(action: {
                showingAppIcon = true
            }) {
                HStack {
                    Text("App Icon")
                    Spacer()
                    Text(currentIcon == "AppIcon" ? "Default" : currentIcon)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: true, vertical: false)
                    Image(currentIcon + "Icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    Spacer().frame(width: 7)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.tertiaryLabel)
                }
            }
            .foregroundColor(.primary)
            .sheet(isPresented: $showingAppIcon) {
                AppIconView()
            }
            
            
        } header: {
            Text("Preferences")
        }
        
        Section {
            HStack {
                Text("Default Sort Mode")
                
                Spacer()
                
                Picker("Default Sort Mode", selection: $defaultSortMode) {
                    ForEach(SortMode.allCases, id: \.self) {
                        Text($0.id)
                    }
                }
                .labelsHidden()
                .pickerStyle(SegmentedPickerStyle())
                .scaleEffect(0.8, anchor: .trailing)
                
            }
            
            Toggle(isOn: $hideScrollBar) {
                Text("Hide Scroll Bar")
            }
            
            Toggle(isOn: $exactHeaders) {
                Text("Exact Date Headers")
            }
        } footer: {
            Text("Will show exact dates (ex. Sunday, Sep 26) in place of relative dates (ex. 3 Days Ago)")
                .fixedSize(horizontal: false, vertical: true)
        }
        
        Section {
            Toggle(isOn: $showLate) {
                Text("Show Late Assignments")
            }
        } footer: {
            Text("The Canvas API only delivers late assignments that are over one day late.")
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    struct AppIconView: View {
        @Environment(\.presentationMode) var presentationMode
        @AppStorage("icon", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var currentIcon: String = "AppIcon"
        
        var body: some View {
            NavigationView {
                List {
                    ForEach(iconGroups, id: \.self) { group in
                        if let name = group.name {
                            Section(header: Text(name)) {
                                ForEach(group.icons, id: \.self) { iconName in
                                    IconItem(iconName: iconName, currentIcon: $currentIcon)
                                        .listRowBackground(Color(.systemGroupedBackground))
                                }
                            }
                        } else {
                            Section {
                                ForEach(group.icons, id: \.self) { iconName in
                                    IconItem(iconName: iconName, currentIcon: $currentIcon)
                                        .listRowBackground(Color(.systemGroupedBackground))
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .introspectTableView { tableView in
                    tableView.backgroundColor = .black
                }
                .background(Color.black.edgesIgnoringSafeArea(.all))
                .navigationTitle("App Icon")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.down")
                        }
                    }
                }
            }
            .background(Color.black)
        }
        
        struct IconItem: View {
            let iconName: String
            @Binding var currentIcon: String
            
            var body: some View {
                Button(action: {
                    UIApplication.shared.setAlternateIconName(iconName == "AppIcon" ? nil : iconName.replacingOccurrences(of: " ", with: ""), completionHandler: { error in
                        if let error = error {
                            print(error)
                        } else {
                            currentIcon = iconName
                        }
                    })
                }) {
                    HStack {
                        Image(iconName + "Icon")
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding()
                        Text(iconName == "AppIcon" ? "Default" : iconName)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if iconName == currentIcon {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                                .padding()
                        }
                    }
                }
                .buttonStyle(.borderless)
            }
        }
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
