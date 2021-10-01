//
//  LicensesView.swift
//  Acrylic
//
//  Created by Ben K on 9/30/21.
//

import SwiftUI

struct License: Hashable {
    let name: String
    let url: URL
}

struct LicensesView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let licenseGroups = [[License(name: "Canvas LMS", url: URL(string: "https://www.google.com")!)]]
    
    var body: some View {
        ForEach(licenseGroups, id: \.self) { licenseArray in
            Section {
                ForEach(licenseArray, id: \.self) { license in
                    LicenseView(license: license)
                }
            }
        }
        .navigationTitle("Licenses")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    struct LicenseView: View {
        let license: License
        
        var body: some View {
            Link(destination: license.url) {
                HStack {
                    Text(license.name)
                        .foregroundColor(.primary)
                    Spacer()
                    Text("License")
                        .font(.callout)
                }
            }
        }
    }
}

struct LicensesView_Previews: PreviewProvider {
    static var previews: some View {
        LicensesView()
    }
}
