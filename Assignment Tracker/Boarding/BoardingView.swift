//
//  BoardingView.swift
//  Assignment Tracker
//
//  Created by Ben K on 9/13/21.
//

import SwiftUI

struct BoardingView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var tab = 0
    @State private var isLastItem = false
    
    var body: some View {
        ZStack {
            TabView(selection: $tab) {
                WelcomeView(tab: $tab)
                    .tag(0)
                SetupView()
                    .tag(1)
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
            .onChange(of: tab) { value in
                withAnimation {
                    if value >= 1 {
                        isLastItem = true
                    } else {
                        isLastItem = false
                    }
                }
            }
            
            
            /*VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        if !isLastItem {
                            withAnimation { tab += 1 }
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(Circle())
                            .rotationEffect(.degrees(!isLastItem ? 0 : 90))
                    }
                    .padding(20)
                }
            }*/
        }
    }
    
    struct WelcomeView: View {
        @Binding var tab: Int
        
        var body: some View {
            VStack {
                Text("Welcome to")
                    .font(.system(size: 60))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                Text("APPNAME")
                    .font(.system(size: 60))
                    .bold()
                    .gradientForeground(colors: [.red, .orange, .yellow, .green, .blue, .purple])
                Text("Easily track and view your assignments both in-app and in the included widget")
                    .foregroundColor(.secondary)
                    .italic()
                    .padding()
                    .padding(.bottom)
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    withAnimation {
                        tab = 1
                    }
                }) {
                    Text("Get Started \(Image(systemName: "chevron.right"))")
                        .foregroundColor(.primary)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
            }
            .padding()
            .offset(x: 0, y: -30)
        }
    }
    
    struct SetupView: View {
        @Environment(\.presentationMode) var presentationMode
        
        @AppStorage("auth", store: UserDefaults(suiteName: "group.com.benk.assytrack")) var authCode: String = ""
        @AppStorage("prefixes", store: UserDefaults(suiteName: "group.com.benk.assytrack")) var prefixes: [String] = []
        
        @State private var editPrefix = false
        @State private var editAuth = false
        
        @State private var userFetchState: FetchState = .unstarted
        
        @State private var userName: String = ""
        @State private var pfp: UIImage?
        
        @State private var showDismiss = false
            
        enum FetchState {
            case unstarted, success, loading, failure
        }
        
        var body: some View {
            VStack {
                Text("Setup")
                    .font(.system(size: 40))
                    .gradientForeground(colors: [.red, .orange, .yellow, .green, .blue, .purple])
                
                Text("A prefix and auth code are required to access Canvas")
                    .foregroundColor(.secondary)
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.top, 5)
                    
                Spacer().frame(height: 20)
                
                Form {
                    Section(header: Color.clear.frame(width: 0, height: 0)) {
                        Button(action: {
                            editPrefix = true
                        }) {
                            HStack {
                                Text("Prefixes")
                                Spacer()
                                if !prefixes.isEmpty {
                                    Text(prefixes.joined(separator: ", "))
                                        .lineLimit(1)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: 150, alignment: .trailing)
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
                        .sheet(isPresented: $editPrefix, onDismiss: loadUser) {
                            Settings.CanvasSettings.PrefixView(prefixes: $prefixes)
                        }
                        
                        Button(action: {
                            editAuth = true
                        }) {
                            HStack {
                                Text("Auth Code")
                                Spacer()
                                if authCode != "" {
                                    SecureField("", text: $authCode)
                                        .disabled(true)
                                        .lineLimit(1)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: 150, alignment: .trailing)
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
                        .fullScreenCover(isPresented: $editAuth, onDismiss: loadUser) {
                            Settings.CanvasSettings.AuthView(authCode: $authCode)
                        }
                    }
                }
                .frame(height: 150)
                .introspectTableView { tableView in
                    tableView.showsVerticalScrollIndicator = false
                    tableView.sectionHeaderHeight = 0
                    tableView.sectionFooterHeight = 0
                    tableView.isScrollEnabled = false
                    tableView.contentInset = .zero
                    tableView.backgroundColor = .clear
                }
                .offset(x: 0, y: -30)
                
                Group {
                    if !prefixes.isEmpty && authCode != "" {
                        switch userFetchState {
                        case .loading:
                            ProgressView()
                        case .success:
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                                .padding(40)
                            
                        default:
                            Image(systemName: "xmark.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.red)
                                .padding(40)
                        }
                    } else {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                            .padding(40)
                    }
                }
                .frame(height: 50)
                .offset(x: 0, y: -25)
                
                if showDismiss {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Close Setup \(Image(systemName: "chevron.down"))")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                    .padding(20)
                    .offset(x: 0, y: -15)
                }
            }
            .padding()
            .onAppear { loadUser() }
            .onChange(of: userFetchState) { value in
                if !prefixes.isEmpty && authCode != "" && value == .success {
                    withAnimation {
                        showDismiss = true
                    }
                } else {
                    withAnimation {
                        showDismiss = false
                    }
                }
            }
            .onChange(of: prefixes) { _ in
                if prefixes.isEmpty {
                    withAnimation {
                        showDismiss = false
                    }
                }
            }
            .onChange(of: authCode) { _ in
                if authCode == "" {
                    withAnimation {
                        showDismiss = false
                    }
                }
            }
        }
        
        func loadUser() {
            self.pfp = nil
            let defaults = UserDefaults.init(suiteName: "group.com.benk.assytrack")
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
            return
        }
        
        func fetchImage(url: URL) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else { return }
                let defaults = UserDefaults.init(suiteName: "group.com.benk.assytrack")
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
    }
}

struct BoardingView_Previews: PreviewProvider {
    static var previews: some View {
        BoardingView()
            .preferredColorScheme(.dark)
    }
}
