//
//  TrackListViewModel.swift
//  itunes-search-player
//
//  Created by Melody Lee on 2024/6/26.
//

import Foundation
import RxCocoa
import RxSwift

class TrackListViewModel {
    let tracks = BehaviorSubject<[Track]>(value: [])
    let error = PublishSubject<SearchError>()
    private let disposeBag = DisposeBag()

    var onError: ((SearchError) -> Void)?
    var onReceiveTracks: (()-> Void)?
    
    func fetchDatas(text: String) {
        guard var urlComponents = URLComponents(string: "https://itunes.apple.com/search") else {
            print("url components fail")
            return
        }
        urlComponents.queryItems = [URLQueryItem(name: "term", value: text)]
        URLSession.shared.dataTask(with: urlComponents.url!) { (data, response, error) in
            if let error = error {
                self.error.onNext(.urlSessionError(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                if let httpResponse = response as? HTTPURLResponse {
                    self.error.onNext(.badResponse(httpResponse.statusCode))
                }
                self.error.onNext(.unexpectedError)
                return
            }

            guard let data = data else {
                self.error.onNext(.noData)
                return
            }

            do {
                let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
                self.tracks.onNext(searchResult.results)
                print("fetch searchtext success.")
            } catch {
                self.error.onNext(.decodeDataFail)
            }
        }.resume()
    }
}
