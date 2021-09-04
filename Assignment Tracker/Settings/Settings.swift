//
//  Settings.swift
//  Assignment Tracker
//
//  Created by Ben K on 8/31/21.
//

import SwiftUI
import UIKit

struct Settings: View {
    @AppStorage("Auth") var savedValue: String = ""
    @AppStorage("prefixes") var prefixes: [String] = []
    
    var body: some View {
        NavigationView {
            Form {
                CanvasSettings()
            }
            .navigationTitle("Settings")
        }
    }
    
    struct CanvasSettings: View {
        @AppStorage("Auth") var authCode: String = ""
        @AppStorage("prefixes") var prefixes: [String] = []
        
        @State private var showingAuthInfo = false
        
        @State private var userFetchState: FetchState = .unstarted
        
        @State private var userName: String = ""
        @State private var pfp: UIImage?
            
        enum FetchState {
            case unstarted, success, loading, failure
        }
        
        var body: some View {
            Section(header: Text("Canvas Authentication")) {
                NavigationLink(destination: PrefixView(prefixes: $prefixes)) {
                    HStack {
                        Text("Prefixes")
                        Spacer()
                        Text(prefixes.joined(separator: ", "))
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: 200, alignment: .trailing)
                            
                    }
                }
                
                HStack {
                    SecureField("Authentication Code", text: $authCode)
                        .disableAutocorrection(true)
                    
                    Spacer()
                    
                    if authCode == "" {
                        Button(action: {
                            showingAuthInfo = true
                        }) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        switch userFetchState {
                        case .loading:
                            ProgressView()
                        case .success:
                            if let pfp = pfp {
                                Image(uiImage: pfp)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(Circle())
                                    .frame(width: 20, height: 20)
                            } else {
                                Image(systemName: "checkmark")
                            }
                        default:
                            Image(systemName: "exclamationmark.circle")
                                .foregroundColor(.red)
                        }
                    }
                }
                .onAppear() { loadUser() }
                .onChange(of: authCode) { _ in loadUser() }
            }
        }
        
        func loadUser() {
            self.pfp = nil
            for prefix in prefixes {
                userFetchState = .loading
                let urlString = "https://\(prefix).instructure.com/api/v1/users/self/profile"
                guard let url = URL(string: urlString) else {
                    userFetchState = .failure
                    print("URL Failure")
                    return
                }
                var request = URLRequest(url: url)
                request.allHTTPHeaderFields = ["Authorization" : "Bearer " + authCode]
                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let response = response, let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 401 {
                            userFetchState = .failure
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
        }
        
        func fetchImage(url: URL) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else { return }
                if let pfp = UIImage(data: data) {
                    self.pfp = pfp
                }
            }.resume()
        }
        
        struct AuthInfo: View {
            var body: some View {
                NavigationView {
                    
                }
            }
        }
        
        struct PrefixView: View {
            @Binding var prefixes: [String]
            
            @State private var addNew = false
            
            var body: some View {
                List {
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
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Prefixes")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button(action: {
                    addNew = true
                }) {
                    Image(systemName: "plus")
                }.padding([.vertical, .leading]))
                .sheet(isPresented: $addNew) {
                    AddPrefix(prefixes: $prefixes)
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
                                .padding(.bottom, 1)
                                .padding(.horizontal)
                            
                            Text("Prefixes tell the app which institutions to load.")
                                .font(.headline)
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
                                    .foregroundColor(Color.primary)
                                    .padding(.vertical, 10)
                                    .overlay(Rectangle().frame(height: 2).padding(.top, 35).padding(.trailing,10))
                                    .foregroundColor(Color.blue)
                            }
                            .padding(20)
                            
                            Spacer()
                        }
                        .navigationBarTitle("New Prefix")
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarItems(leading: Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }.padding([.trailing]), trailing: Button("Add") {
                            prefixes.append(prefix)
                            presentationMode.wrappedValue.dismiss()
                        }.padding([.leading]).disabled(prefix == ""))
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
