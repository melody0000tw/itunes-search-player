//
//  SearchError.swift
//  itunes-search-player
//
//  Created by Melody Lee on 2024/6/26.
//

import Foundation

enum SearchError: Error {
    case decodeDataFail
    case badResponse(Int)
    case noData
    case unexpectedError
    case urlSessionError(Error)
}
