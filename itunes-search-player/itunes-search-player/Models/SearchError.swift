//
//  SearchError.swift
//  itunes-search-player
//
//  Created by Melody Lee on 2024/6/26.
//

import Foundation

enum SearchError: Error {
    case decodeDataFail
    case unexpectedError
    case urlError(Error)
    
    var errorMessage: String {
        switch self {
        case .decodeDataFail:
            return "decode error"
        case .unexpectedError:
            return "unexpected error"
        case .urlError(_):
            return "network error"
        }
    }
}
