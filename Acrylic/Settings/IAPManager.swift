//
//  IAPManager.swift
//  Acrylic
//
//  Created by Ben K on 9/26/21.
//

import Foundation
import StoreKit
import Combine

class IAPManager: NSObject {
  static let shared = IAPManager()
  private override init() {
    super.init()
  }
}
