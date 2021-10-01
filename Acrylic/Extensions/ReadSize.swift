//
//  ReadSize.swift
//  Assignment Tracker
//
//  Created by Ben K on 9/9/21.
//

import SwiftUI


struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {
  func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Color.clear
          .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
      }
    )
    .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
  }
}

/* USAGE
 
 var body: some View {
   childView
     .readSize { newSize in
       print("The new child size is: \(newSize)")
     }
 }
 
 */
