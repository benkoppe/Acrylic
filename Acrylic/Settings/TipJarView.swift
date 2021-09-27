//
//  TipJarView.swift
//  Acrylic
//
//  Created by Ben K on 9/26/21.
//

import SwiftUI

struct TipJarButton: View {
    @State private var tipJar = false
    
    var body: some View {
        Section {
            HStack {
                Button("Tip Jar") {
                    tipJar = true
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.tertiaryLabel)
            }
            .foregroundColor(.primary)
        }
        .sheet(isPresented: $tipJar) {
            TipJarView()
        }
    }
}

struct TipJarView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Capsule()
                    .foregroundColor(.secondary)
                    .frame(width: 100, height: 3)
                    .padding(.bottom)
                
                Text("Tip Jar")
                    .bold()
                    .font(.title)
                    .padding(.top)
                
                Image(systemName: "gift.fill")
                    .font(.title)
                    .padding(12)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.top, 5)
                
                Text("If you enjoy Acrylic and would like to donate a bit to show your support, I would really appreciate it!")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 20)
                
                List {
                    SingleTip(tipName: "Nice Tip 😃", tipAmount: 1)
                    SingleTip(tipName: "Kind Tip 😊", tipAmount: 3)
                    SingleTip(tipName: "Generous Tip 😘", tipAmount: 5)
                }
                .introspectTableView { tableView in
                    tableView.isScrollEnabled = false
                }
                
                Spacer()
                
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Close")
                        .font(.headline)
                        .padding()
                }
            }
            .padding()
            .navigationTitle("Tip Jar")
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    struct SingleTip: View {
        let tipName: String
        let tipAmount: Double
        
        var body: some View {
            HStack {
                Text(tipName)
                Spacer()
                Button("$\(String(format: "%.2f", tipAmount))") {
                    
                }
                .buttonStyle(.plain)
                .foregroundColor(.primary)
                .padding(.vertical, 5)
                .padding(.horizontal, 15)
                .background(Color.blue)
                .clipShape(Capsule())
            }
            .padding(7)
        }
    }
}

struct TipJarView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
            .sheet(isPresented: .constant(true)) {
                TipJarView()
            }
    }
}
