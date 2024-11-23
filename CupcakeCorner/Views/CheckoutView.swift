//
//  CheckoutView.swift
//  CupcakeCorner
//
//  Created by Saverio Negro on 16/11/24.
//

import SwiftUI

struct CheckoutView: View {
    
    var order: Order
    @State private var confirmationMessage = ""
    @State private var showingConfirmation = false
    @State private var errorMessage = ""
    @State private var showingError = false
    
    func placeOrder() async {
        // Encode data to send
        guard let encoded = try? JSONEncoder().encode(order) else {
            print("Failed to encode order.")
            return
        }
        
        // Create the URL
        guard let url = URL(string: "https://reqres.in/api/cupcakes") else {
            print("Invalid URL.")
            return
        }
        
        // Configure the HTTP request using URLRequest
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
                confirmationMessage = "Your order for \(decodedOrder.quantity)x \(Order.types[order.type].lowercased()) cupcakes is on its way!"
                
            } catch {
                print("Error while decoding the data: \(error.localizedDescription)")
            }
            
            // Show alert
            showingConfirmation = true
            
        } catch {
            print("Checkout failed: \(error.localizedDescription)")
            errorMessage = "Checkout failed: \(error.localizedDescription)"
            showingError = true
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
                Text(confirmationMessage)
            }
            .alert("Sorry!", isPresented: $showingError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }
}

#Preview {
    CheckoutView(order: Order())
}
