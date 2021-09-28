//
//  HiddenView.swift
//  Acrylic
//
//  Created by Ben K on 9/28/21.
//

import SwiftUI

struct HiddenView: View {
    @EnvironmentObject var hiddenAssignments: AssignmentArray
    
    var body: some View {
        Section {
            ForEach(hiddenAssignments.assignments, id: \.id) { assignment in
                Text(assignment.name)
            }
            .onDelete(perform: delete)
        }
    }
    
    func delete(at offsets: IndexSet) {
        hiddenAssignments.assignments.remove(atOffsets: offsets)
    }
}

struct HiddenView_Previews: PreviewProvider {
    static var previews: some View {
        HiddenView()
    }
}
