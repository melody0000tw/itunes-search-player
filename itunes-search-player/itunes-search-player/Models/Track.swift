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

struct Track: Hashable {
    let trackId: Int?
    let trackName: String?
    let trackTimeMillis: Int?
    let longDescription: String?
    let artworkURL100: String?
    let previewURL: String?
}
