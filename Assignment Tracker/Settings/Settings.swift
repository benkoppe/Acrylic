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
    
    init() {
        
    }
    
    var body: some View {
        Form {
            CanvasSettings()
            
            Preferences()
            
            Contact()
            
            License()
            
            if prefixes.contains("devtools") {
                DevTools()
            }
            
            
        }
        .introspectTableView { tableView in
            tableView.contentOffset = CGPoint(x: 0, y: -40)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    struct CanvasSettings: View {
        @AppStorage("auth", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var authCode: String = ""
        @AppStorage("prefixes", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var prefixes: [String] = []
        
        @State private var showingPrefixes = false
        @State private var showingAuth = false
        
        @State private var userFetchState: FetchState = .unstarted
        
        @State private var userName: String = ""
        @State private var pfp: UIImage?
            
        enum FetchState {
            case unstarted, success, loading, failure
        }
        
        var body: some View {
            Section(header: Text("Canvas Authentication")) {
                Button(action: {
                    showingPrefixes = true
                }) {
                    HStack {
                        Text("Prefixes")
                        Spacer()
                        if !prefixes.isEmpty {
                            Text(prefixes.joined(separator: ", "))
                                .lineLimit(1)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: 200, alignment: .trailing)
                        } else {
                            Image(systemName: "exclamationmark.circle")
                                .foregroundColor(.red)
                        }
                        Spacer().frame(width: 5)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.tertiaryLabel)
                    }
                }
                .foregroundColor(.primary)
                .sheet(isPresented: $showingPrefixes, onDismiss: loadUser) {
                    PrefixView(prefixes: $prefixes)
                }
                
                HStack {
                    Button(action: {
                        showingAuth = true
                    }) {
                        HStack {
                            Text("Auth Code")
                            Spacer()
                            
                            switch userFetchState {
                            case .loading:
                                ProgressView()
                            case .success:
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.green)
                            default:
                                Image(systemName: "exclamationmark.circle")
                                    .foregroundColor(.red)
                            }
                            
                            Spacer().frame(width: 5)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.tertiaryLabel)
                        }
                    }
                    .foregroundColor(.primary)
                    .fullScreenCover(isPresented: $showingAuth, onDismiss: loadUser) {
                        AuthView(authCode: $authCode)
                    }
                }
                .onAppear() { loadUser() }
                .onChange(of: authCode) { _ in
                    loadUser()
                }
                .onChange(of: prefixes) { _ in
                    print("running")
                    loadUser()
                }
            }
        }
        
        func loadUser() {
            self.pfp = nil
            let defaults = UserDefaults.init(suiteName: "group.com.benk.acrylic")
            for prefix in prefixes {
                userFetchState = .loading
                let urlString = "https://\(prefix).instructure.com/api/v1/users/self/profile"
                guard let url = URL(string: urlString) else {
                    userFetchState = .failure
                    print("URL Failure")
                    defaults?.setValue(nil, forKey: "pfp")
                    return
                }
                var request = URLRequest(url: url)
                request.allHTTPHeaderFields = ["Authorization" : "Bearer " + authCode]
                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let response = response, let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 401 {
                            userFetchState = .failure
                            defaults?.setValue(nil, forKey: "pfp")
                            return
                        }
                        if httpResponse.statusCode == 404 {
                            userFetchState = .failure
                            defaults?.setValue(nil, forKey: "pfp")
                            return
                        }
                    }
                    if let data = data {
                        let decoder = JSONDecoder()
                        if let list = try? decoder.decode(CanvasUser.self, from: data) {
                            userName = list.name
                            if let pfpURLString = list.avatarURL, let pfpURL = URL(string: pfpURLString)  {
                                fetchImage(url: pfpURL)
                            }
                            userFetchState = .success
                            return
                        }
                    } else {
                        print("Failure")
                        userFetchState = .failure
                    }
                }.resume()
            }
            if prefixes.isEmpty {
                defaults?.setValue(nil, forKey: "pfp")
                userFetchState = .failure
            }
            return
        }
        
        func fetchImage(url: URL) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else { return }
                let defaults = UserDefaults.init(suiteName: "group.com.benk.acrylic")
                if let pfp = UIImage(data: data) {
                    if let pngData = pfp.pngData() {
                        defaults?.setValue(pngData, forKey: "pfp")
                    } else {
                        defaults?.setValue(nil, forKey: "pfp")
                    }
                    self.pfp = pfp
                }
            }.resume()
        }
        
        struct AuthView: View {
            @Environment(\.presentationMode) var presentationMode
            
            @Binding var authCode: String
            @State private var editCode: String = ""
            
            @State private var isSecure = false
            
            var body: some View {
                NavigationView {
                    ScrollView {
                        VStack(alignment: .center) {
                            Text("A Canvas Authentication Token is required to access your assignments.")
                                .font(.title2)
                                .bold()
                                .multilineTextAlignment(.center)
                                .padding(.top, 30)
                                .padding(.bottom)
                                .padding(.horizontal)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            /*Image("Instructions")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)*/
                            
                            Spacer()
                            
                            Group {
                                Image("Settings")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100)
                                    .padding(3)
                                Image(systemName: "arrow.down")
                                Image("NewToken")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200)
                                    .padding(3)
                                Image(systemName: "arrow.down")
                                Image("GenerateToken")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150)
                                    .padding(3)
                            }
                            
                            HStack(spacing: 0) {
                                
                                /*if !isSecure {
                                    
                                    TextField("Authentication Code", text: $editCode)
                                        .lineLimit(1)
                                        .disableAutocorrection(true)
                                        .autocapitalization(.none)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                } else {
                                    
                                    SecureField("Authentication Code", text: $editCode)
                                        .lineLimit(1)
                                        .disableAutocorrection(true)
                                        .autocapitalization(.none)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .disabled(true)
                                        .contrast(0.9)
                                    
                                    Button("Clear") {
                                        withAnimation { isSecure.toggle() }
                                        editCode = ""
                                    }
                                    .padding(.horizontal)
                                    
                                }*/
                                
                                TextField("Authentication Code", text: $editCode)
                                    .lineLimit(1)
                                    .disableAutocorrection(true)
                                    .autocapitalization(.none)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disabled(isSecure)
                                    .contrast(isSecure ? 0.7 : 1)
                                    .introspectTextField { textField in
                                        textField.isSecureTextEntry = isSecure
                                    }
                                
                                if isSecure {
                                    Button("Clear") {
                                        withAnimation { isSecure.toggle(); editCode = "" }
                                    }
                                    .padding(.horizontal)
                                }
                                
                                //Spacer().frame(width: 5)
                                
                                /*Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                                    .padding(.horizontal)(*/
                            }
                            .padding(.horizontal)
                            .padding(.top, 20)
                            
                            Text("Your code will only be stored on-device, and Canvas will only be accessed for display purposes.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .italic()
                                .multilineTextAlignment(.center)
                                .padding()
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                        }
                        .onAppear() { editCode = authCode; if !authCode.isEmpty { isSecure = true } }
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarTitle("Set Auth Code")
                        .navigationBarItems(leading: Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Cancel")
                        }.padding([.vertical, .trailing]), trailing: Button(action: {
                            authCode = editCode
                            presentationMode.wrappedValue.dismiss()
                        }){
                            Text("Done")
                        }.padding([.vertical, .leading]))
                    }
                    .background(Color(.secondarySystemBackground).ignoresSafeArea(.all))
                }
            }
        }
        
        struct PrefixView: View {
            @Environment(\.presentationMode) var presentationMode
            
            @Binding var prefixes: [String]
            
            @State private var addNew = false
            
            var body: some View {
                NavigationView {
                    List {
                        if !prefixes.isEmpty {
                            ForEach(prefixes, id: \.self) { prefix in
                                Group {
                                    Text("https://")
                                        .foregroundColor(.tertiaryLabel)
                                        + Text(prefix)
                                        .foregroundColor(.primary)
                                        + Text(".instructure.com/")
                                        .foregroundColor(.tertiaryLabel)
                                }
                            }
                            .onDelete(perform: delete)
                        } else {
                            Text("Please add at least one prefix.")
                                .font(.callout)
                                .italic()
                                .foregroundColor(.red)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .navigationTitle("Prefixes")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(leading: Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) { Image(systemName: "chevron.down") }.padding([.vertical, .trailing]), trailing: Button(action: {
                        addNew = true
                    }) {
                        Image(systemName: "plus")
                    }.padding([.vertical, .leading]))
                    .fullScreenCover(isPresented: $addNew) {
                        AddPrefix(prefixes: $prefixes)
                    }
                }
            }
            
            func delete(at offsets: IndexSet) {
                prefixes.remove(atOffsets: offsets)
            }
            
            func move(from source: IndexSet, to destination: Int) {
                prefixes.move(fromOffsets: source, toOffset: destination)
            }
            
            struct AddPrefix: View {
                @Environment(\.presentationMode) private var presentationMode
                @Binding var prefixes: [String]
                
                @State private var prefix = ""
                
                var body: some View {
                    NavigationView {
                        VStack {
                            Text("Every institution uses different Canvas URLS.")
                                .font(.title)
                                .bold()
                                .multilineTextAlignment(.center)
                                .padding(.top, 30)
                                .padding(.horizontal)
                            
                            Spacer().frame(height: 12)
                            
                            Text("Prefixes tell the app which institutions to load.")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .padding(.bottom, 30)
                            
                            Text("To add a prefix, check the beginning of your Canvas URL:")
                                .font(.system(.caption, design: .rounded))
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                            
                            Spacer()
                                .frame(height: 6)
                            
                            Group {
                                Text("https://")
                                    .foregroundColor(.secondary)
                                    + Text("hsccsd")
                                    .foregroundColor(.primary)
                                    + Text(".instructure.com/")
                                    .foregroundColor(.secondary)
                            }
                            .font(.system(.body , design: .rounded))
                            
                            HStack {
                                Text("Prefix")
                                    .padding(.trailing, 5)
                                
                                TextField("hsccsd", text: $prefix)
                                    .disableAutocorrection(true)
                                    .autocapitalization(.none)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    //.foregroundColor(Color.primary)
                                    //.padding(.vertical, 10)
                                    //.overlay(Rectangle().frame(height: 2).padding(.top, 35).padding(.trailing,10))
                                    //.foregroundColor(Color.blue)
                            }
                            .padding(20)
                            
                            Spacer()
                        }
                        .background(Color(.secondarySystemBackground).ignoresSafeArea(.all))
                        .navigationBarTitle("New Prefix")
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarItems(leading: Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }.padding([.vertical, .trailing]), trailing: Button("Add") {
                            prefixes.append(prefix)
                            presentationMode.wrappedValue.dismiss()
                        }.padding([.vertical, .leading]).disabled(prefix == ""))
                    }
                }
            }
        }
    }
    
    struct Preferences: View {
        @AppStorage("showLate", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var showLate: Bool = true
        @AppStorage("icon", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var currentIcon: String = "AppIcon"
        @State private var showingAppIcon = false
        
        
        var body: some View {
            Section(header: Text("Preferences"), footer: Text("The Canvas API only delivers late assignments that are over one day late.").fixedSize(horizontal: false, vertical: true).padding(.bottom)) {
                
                Button(action: {
                    showingAppIcon = true
                }) {
                    HStack {
                        Text("App Icon")
                        Spacer()
                        Text(currentIcon == "AppIcon" ? "Default" : currentIcon)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: 200, alignment: .trailing)
                        Spacer().frame(width: 5)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.tertiaryLabel)
                    }
                }
                .foregroundColor(.primary)
                .sheet(isPresented: $showingAppIcon) {
                    AppIconView()
                }
                
                Toggle(isOn: $showLate) {
                    Text("Show Late Assignments")
                }
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
                    .background(Color.black.edgesIgnoringSafeArea(.all))
                    .introspectTableView { tableView in
                        tableView.backgroundColor = .black
                    }
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
                        UIApplication.shared.setAlternateIconName(iconName == "AppIcon" ? nil : iconName, completionHandler: { error in
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
    
    struct Contact: View {
        @State private var contactMailData = ComposeMailData(subject: "[Acrylic \(Bundle.main.releaseVersionNumber ?? "VERSION NOT FOUND") (\(Bundle.main.buildVersionNumber ?? "BUILD NOT FOUND"))]", recipients: ["Koppe.Development@gmail.com"], message: "", attachments: [])
        @State private var showContactMail = false
        
        var body: some View {
            Section(header: Text("Contact")) {
                Button("Email") {
                    showContactMail = true
                }
                .sheet(isPresented: $showContactMail) {
                    MailView(data: $contactMailData) { result in
                        print(result)
                    }
                }
                
                Button("Instagram") {
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
                }
            }
        }
    }
    
    struct License: View {
        var body: some View {
            Section {
                Link(destination: URL(string: "https://github.com/instructure/canvas-lms/blob/master/LICENSE")!) {
                    Text("Canvas LMS License")
                }
            }
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
