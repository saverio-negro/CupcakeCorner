//
//  MusicData.swift
//  CupcakeCorner
//
//  Created by Saverio Negro on 12/11/24.
//

import SwiftUI

struct MusicData: Codable {
    let results: [Result]
}

struct Result: Codable {
    let trackId: Int
    let trackName: String
    let collectionName: String
}
