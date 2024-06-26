//
//  ViewController.swift
//  itunes-search-player
//
//  Created by Melody Lee on 2024/6/24.
//

import UIKit
import Kingfisher

class ViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var formatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        return formatter
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Track>!
    private var datas: [Track] = []
    
    private var playingCell: TrackCell?
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDataSource()
//        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
//        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Setups
    private func configureUI() {
        searchButton.layer.cornerRadius = 6
        searchButton.addTarget(self, action: #selector(search), for: .touchUpInside)
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchTextField.delegate = self
        collectionView.delegate = self
        collectionView.isUserInteractionEnabled = true
        collectionView.collectionViewLayout = configureLayout()
        collectionView.register(UINib(nibName: TrackCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: TrackCell.reuseIdentifier)
    }
    
    private func configureLayout() -> UICollectionViewCompositionalLayout {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(160))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
        
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Track>(collectionView: self.collectionView) {
            (collectionView, indexPath, track) -> UICollectionViewCell in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackCell.reuseIdentifier, for: indexPath) as? TrackCell else {
                return UICollectionViewCell()
            }
            cell.trackNameLabel.text = track.trackName
            cell.descriptionLabel.text = track.longDescription
            cell.imageView.kf.setImage(with: URL(string: track.artworkUrl100!))
            if let millis = track.trackTimeMillis {
                cell.timeLabel.text = self.getformattedTime(millis: millis)
            }
            return cell
        }
        collectionView.dataSource = dataSource
        updateDatas()
    }
    
    // MARK: - Datas
    private func updateDatas() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Track>()
        snapshot.appendSections([.main])
        snapshot.appendItems(datas)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func fetchDatas(text: String) {
        guard var urlComponents = URLComponents(string: "https://itunes.apple.com/search") else {
            print("url components fail")
            return
        }
        urlComponents.queryItems = [URLQueryItem(name: "term", value: text)]
        URLSession.shared.dataTask(with: urlComponents.url!) { (data, response, error) in
            if let error = error {
                print("Networking error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error with response code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                return
            }

            guard let data = data else {
                print("No data received from the server")
                return
            }

            do {
                let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
                self.datas = searchResult.results
                self.updateDatas()
                print("fetch searchtext success:")
                print("result: \(self.datas)")
            } catch {
                print("failed")
            }
        }.resume()
    }
    
    private func getformattedTime(millis: Int) -> String {
        let timestamp: TimeInterval = Double(millis) / 1000.0
        let date = Date(timeIntervalSince1970: timestamp)
        let formattedTime = formatter.string(from: date)
        return formattedTime
    }
    
    // MARK: - Interactions
    @objc func search() {
        print("did tapped searchBtn")
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        print("search text: \(text)")
        playingCell?.stopVideo()
        fetchDatas(text: text)
    }
    
//    @objc func dismissKeyboard() {
//        view.endEditing(true)
//    }
}

// MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackCell,
              let urlString = datas[indexPath.row].previewUrl,
              let url = URL(string: urlString) else { return }
        
        // 正在播放中的 cell
        if cell == playingCell {
            if cell.isPlaying {
                cell.stopVideo()
            } else {
                cell.playVideo()
            }
        } else {
            // 不是正在播放中的cell
            playingCell?.deinitVideo()
            playingCell?.toggleStatusLabel()
            cell.configureVideo(url: url)
            cell.playVideo()
            playingCell = cell
        }
        
        cell.toggleStatusLabel()
    }
}
