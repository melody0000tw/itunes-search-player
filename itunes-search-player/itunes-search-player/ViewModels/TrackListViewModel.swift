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
        
        let urlRequest = URLRequest(url: urlComponents.url!)
        URLSession.shared.rx.data(request: urlRequest)
            .observe(on: MainScheduler.instance)
            .map { data -> [Track] in
                let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
                return searchResult.results
            }
            .subscribe { [weak self] tracks in
                self?.tracks.onNext(tracks)
            } onError: { [weak self] error in
                if error is URLError {
                    self?.error.onNext(.urlError(error))
                } else if error is DecodingError {
                    self?.error.onNext(.decodeDataFail)
                } else {
                    self?.error.onNext(.unexpectedError)
                }
            }.disposed(by: disposeBag)
    }
}
