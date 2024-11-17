//
//  AddressView.swift
//  CupcakeCorner
//
//  Created by Saverio Negro on 16/11/24.
//

import SwiftUI

struct AddressView: View {
    
    @Bindable var order: Order
    
    var body: some View {
        Form {
            Section("Name") {
                TextField("Enter your name", text: $order.name)
            }
            
            Section("Street Address") {
                TextField("Enter your street address", text: $order.streetAddress)
            }
            
            Section("City") {
                TextField("Enter your city", text: $order.city)
            }
            
            Section("Zip") {
                TextField("Enter your zip", text: $order.zip)
            }
                          
            Section {
                NavigationLink("Check out", destination: CheckoutView(order: order))
            }
            .disabled(!order.isAddressValid)
        }
        .navigationTitle("Delivery Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AddressView(order: Order())
}
