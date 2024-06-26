//
//  Track.swift
//  itunes-search-player
//
//  Created by Melody Lee on 2024/6/24.
//

import Foundation

enum Section: Hashable {
    case main
}

struct SearchResult: Codable {
    let resultCount: Int
    let results: [Track]
}

struct Track: Hashable, Codable {
    let trackId: Int?
    let trackName: String?
    let trackTimeMillis: Int?
    let longDescription: String?
    let artworkUrl100: String?
    let previewUrl: String?
}
