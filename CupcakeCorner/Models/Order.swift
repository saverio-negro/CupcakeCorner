//
//  Order.swift
//  CupcakeCorner
//
//  Created by Saverio Negro on 16/11/24.
//

import SwiftUI

@Observable
class Order: Codable {
    
    enum CodingKeys: String, CodingKey {
        case _type = "type"
        case _quantity = "quantity"
        case _specialRequestEnabled = "specialRequestEnabled"
        case _extraFrosting = "extraFrosting"
        case _addSprinkles = "addSprinkles"
        case _name = "name"
        case _streetAddress = "streetAddress"
        case _city = "city"
        case _zip = "zip"
    }
    
    // Order Details
    static let types = ["Vanilla", "Strawberry", "Chocolate", "Rainbow"]
    
    var type = 0
    var quantity = 3
    
    var specialRequestEnabled: Bool = false {
        // Run after the property gets set
        didSet {
            if !specialRequestEnabled {
                extraFrosting = false
                addSprinkles = false
            }
        }
        
        // Run before the property gets set
        willSet {
            
        }
    }
    var extraFrosting = false
    var addSprinkles = false
    
    // Address Details
    var name = ""
    var streetAddress = ""
    var city = ""
    var zip = ""
    var isAddressValid: Bool {
        
        // Clean the address entries for any whitespaces
        name = name.trimmingCharacters(in: .whitespaces)
        streetAddress = streetAddress.trimmingCharacters(in: .whitespaces)
        city = city.trimmingCharacters(in: .whitespaces)
        zip = zip.trimmingCharacters(in: .whitespaces)
        
        if name.isEmpty || streetAddress.isEmpty || city.isEmpty || zip.isEmpty {
            return false
        }
        
        return true
    }
    
    var cost: Decimal {
    
        // $2 per cake
        var cost = Decimal(quantity) * 2.0
        
        // complicated cakes cost more
        cost += Decimal(type) / 2
        
        // $1/cake for extra frosting
        if extraFrosting {
            cost += Decimal(quantity)
        }
        
        // $0.50/cake for sprinkles
        if addSprinkles {
            cost += Decimal(quantity) / 2
        }
        
        return cost
    }
}
