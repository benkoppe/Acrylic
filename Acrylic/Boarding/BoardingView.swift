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
                WidgetView(tab: $tab)
                    .tag(1)
                SetupView()
                    .tag(2)
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
                Spacer()
                Text("Welcome to")
                    .font(.system(size: 40))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .offset(y: 40)
                Text("Acrylic")
                    .font(.system(size: 60))
                    .bold()
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .offset(y: 40)
                Image("BoardingImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .padding(.top)
                Text("Easily track and view your assignments.")
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
                    Text("Next \(Image(systemName: "chevron.right"))")
                        .foregroundColor(.primary)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
                Spacer()
            }
            .padding()
            .offset(x: 0, y: -30)
        }
    }
    
    struct WidgetView: View {
        @Binding var tab: Int
        
        var body: some View {
            VStack {
                Spacer()
                Text("Widget Included")
                    .font(.title)
                    .bold()
                    .padding(.vertical)
                Image("WidgetImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 325, height: 325)
                Text("Comes with a widget for anytime access.")
                    .foregroundColor(.secondary)
                    .italic()
                    .padding()
                    .padding(.bottom)
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    withAnimation {
                        tab = 2
                    }
                }) {
                    Text("Get Started \(Image(systemName: "chevron.right"))")
                        .foregroundColor(.primary)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
                Spacer()
            }
            .padding()
            .offset(x: 0, y: -30)
        }
    }
    
    struct SetupView: View {
        @Environment(\.presentationMode) var presentationMode
        
        @AppStorage("auth", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var authCode: String = ""
        @AppStorage("prefixes", store: UserDefaults(suiteName: "group.com.benk.acrylic")) var prefixes: [String] = []
        
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
                    .bold()
                    //.gradientForeground(colors: [.red, .orange, .yellow, .green, .blue, .purple])
                
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
                                }
                                Spacer().frame(width: 5)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.tertiaryLabel)
                            }
                        }
                        .foregroundColor(.primary)
                        .sheet(isPresented: $editPrefix, onDismiss: { Task { await loadUser() } } ) {
                            CanvasSettingsView.PrefixView(prefixes: $prefixes)
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
                                }
                                Spacer().frame(width: 5)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.tertiaryLabel)
                            }
                        }
                        .foregroundColor(.primary)
                        .fullScreenCover(isPresented: $editAuth, onDismiss: { Task { await loadUser() } } ) {
                            CanvasSettingsView.AuthView(authCode: $authCode)
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
            .task {
                await loadUser()
            }
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
        
        func loadUser() async {
            userFetchState = .loading
            let defaults = UserDefaults.init(suiteName: "group.com.benk.acrylic")
            var userArray: [CanvasUser] = []
            
            do {
                userArray = try await asyncLoadUser(auth: authCode, prefixes: prefixes)
                userFetchState = .success
            } catch {
                print("user error \(error)")
                userFetchState = .failure
            }
            
            if let pngData = await asyncFetchUserImage(userArray: userArray) {
                self.pfp = UIImage(data: pngData)
                defaults?.setValue(pngData, forKey: "pfp")
                return
            }
            
            defaults?.setValue(nil, forKey: "pfp")
        }
    }
}

struct BoardingView_Previews: PreviewProvider {
    static var previews: some View {
        BoardingView()
            .preferredColorScheme(.dark)
    }
}
