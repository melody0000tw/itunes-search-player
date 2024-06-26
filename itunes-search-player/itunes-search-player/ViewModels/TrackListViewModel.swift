//
//  TrackListViewModel.swift
//  itunes-search-player
//
//  Created by Melody Lee on 2024/6/26.
//

import Foundation

class TrackListViewModel {
    var tracks: [Track] = [] {
        didSet {
            if let onReceiveTracks = onReceiveTracks {
                onReceiveTracks()
            }
        }
    }
    var onError: ((SearchError) -> Void)?
    var onReceiveTracks: (()-> Void)?
    
    func fetchDatas(text: String) {
        guard var urlComponents = URLComponents(string: "https://itunes.apple.com/search") else {
            print("url components fail")
            return
        }
        urlComponents.queryItems = [URLQueryItem(name: "term", value: text)]
        URLSession.shared.dataTask(with: urlComponents.url!) { (data, response, error) in
            guard let onError = self.onError else {
                print("no onError code")
                return
            }
            
            if let error = error {
                onError(.urlSessionError(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                if let httpResponse = response as? HTTPURLResponse {
                    onError(.badResponse(httpResponse.statusCode))
                }
                onError(.unexpectedError)
                return
            }

            guard let data = data else {
                onError(.noData)
                return
            }

            do {
                let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
                self.tracks = searchResult.results
                print("fetch searchtext success.")
            } catch {
                onError(.decodeDataFail)
            }
        }.resume()
    }
}
