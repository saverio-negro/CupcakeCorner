//
//  ContentView.swift
//  CupcakeCorner
//
//  Created by Saverio Negro on 12/11/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var results = [Result]()
    
    var body: some View {
        List(results, id: \.self.trackId) { item in
            VStack(alignment: .leading) {
                Text(item.trackName)
                    .font(.headline)
                Text(item.collectionName)
            }
        }
    }
}

#Preview {
    ContentView()
}
