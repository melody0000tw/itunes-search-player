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
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Track>!
    private var datas: [Track] = []
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDataSource()
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Setups
    private func configureUI() {
        searchButton.layer.cornerRadius = 6
        searchButton.addTarget(self, action: #selector(search), for: .touchUpInside)
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchTextField.delegate = self
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
            if let data = data {
                do {
                    let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
                    self.datas = searchResult.results
                    self.updateDatas()
                    print("fetch searchtext success:")
                    print("result: \(self.datas)")
                } catch {
                    print("failed")
                }
            }
        }.resume()
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
        fetchDatas(text: text)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
