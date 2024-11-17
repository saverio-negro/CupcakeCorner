//
//  ContentView.swift
//  CupcakeCorner
//
//  Created by Saverio Negro on 15/11/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var order = Order()
    var extraInfoView: some View {
        Group {
            Toggle("Add extra frosting", isOn: $order.extraFrosting)
            Toggle("Add extra sprinkles", isOn: $order.addSprinkles)
        }
    }
    
    var body: some View {
        
        let specialRequestEnabled = Binding {
            return order.specialRequestEnabled
        } set: { value in
            withAnimation {
                order.specialRequestEnabled = value
            }
        }

        NavigationStack {
            Form {
                Section {
                    Picker("Type of cake", selection: $order.type) {
                        ForEach(Order.types.indices, id: \.self) {
                            Text(Order.types[$0])
                        }
                    }
                    
                    Stepper("^[\(order.quantity) cake](inflect: true)", value: $order.quantity, in: 3...20)
                }
                
                Section {
                    Toggle("Any special requests?", isOn: specialRequestEnabled)
                    if order.specialRequestEnabled {
                        extraInfoView
                    }
                }
                
                Section {
                    NavigationLink("Delivery Details") {
                        AddressView(order: order)
                    }
                }
            }
            .navigationTitle("Cupcake Corner")
        }
    }
}

#Preview {
    ContentView()
}
