//
//  Order.swift
//  CupcakeCorner
//
//  Created by Saverio Negro on 16/11/24.
//

import SwiftUI

@Observable
class Order {
    
    static let types = ["Vanilla", "Strawberry", "Chocolate", "Rainbow"]
    
    var type = 0
    var quantity = 3
    
    var specialRequestEnabled = false
    var extraFrosting = false
    var addSprinkles = false
}
