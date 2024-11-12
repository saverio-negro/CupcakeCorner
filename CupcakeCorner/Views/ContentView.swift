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
        .task {
            guard let url = URL(string: "https://itunes.apple.com/search?term=taylor+swift&entity=song") else {
                print("Invalid URL")
                return
            }
            
            do {
                let (dataJSON, response) = try await URLSession(configuration: .default).data(from: url)
                let decoder = JSONDecoder()
                
                
                guard let data = try? decoder.decode(MusicData.self, from: dataJSON) else {
                    print("Invalid data.")
                    return
                }
                
                results = data.results
                
            } catch {
                print("Invalid URL")
            }
            
        }
    }
}

#Preview {
    ContentView()
}
