//
//  CheckoutView.swift
//  CupcakeCorner
//
//  Created by Saverio Negro on 16/11/24.
//

import SwiftUI

struct CheckoutView: View {
    
    var order: Order
    @State private var confirmatioMessage = ""
    @State private var showingConfirmation = false
    
    func placeOrder() async {
        guard let encoded = try? JSONEncoder().encode(order) else {
            print("Failed to encode order.")
            return
        }
        
        guard let url = URL(string: "https://reqres.in/api/cupcakes") else {
            print("Invalid URL.")
            return
        }
        
        // Configure the HTTP request
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        // Make networking call
        do {
            
            // Send the HTTP request
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            
            // Decode data we got back
            do {
                let decodedOrder = try JSONDecoder().decode(Order.self, from: data)
                
                // Use order information in confirmation message
                confirmatioMessage = "Your order for \(decodedOrder.quantity)x \(Order.types[order.type].lowercased()) cupcakes is on its way!"
                
            } catch {
                print("Error while decoding the data: \(error.localizedDescription)")
            }
            
            // Show alert
            showingConfirmation = true
            
        } catch {
            print("Checkout failed: \(error.localizedDescription)")
        }
    }
    
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
                Button("Place order") {
                    Task {
                        await placeOrder()
                    }
                }
                .padding()
            }
            .navigationTitle("Check out")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Thank you!", isPresented: $showingConfirmation) {
                Button("OK") {}
            } message: {
                Text(confirmatioMessage)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }
}

#Preview {
    CheckoutView(order: Order())
}
