//
//  CheckoutView.swift
//  CupcakeCorner
//
//  Created by Saverio Negro on 16/11/24.
//

import SwiftUI

struct CheckoutView: View {
    
    var order: Order
    
    var body: some View {
        ScrollView {
            VStack {
                
                // Load remote image
                AsyncImage(url: URL(string: "https://hws.dev/img/cupcakes@3x.jpg"), scale: 3) { image in
                    
                    image
                        .resizable()
                        .scaledToFit()
                    
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 233)
                
                // Total order cost
                Text("Your total is \(order.cost, format: .currency(code: "USD"))")
                
                // Button to place order
                Button("Place order", action: {})
                    .padding()
            }
            .navigationTitle("Check out")
            .navigationBarTitleDisplayMode(.inline)
            .scrollBounceBehavior(.basedOnSize)
        }
    }
}

#Preview {
    CheckoutView(order: Order())
}
