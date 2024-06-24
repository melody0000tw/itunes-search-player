//
//  ViewController.swift
//  itunes-search-player
//
//  Created by Melody Lee on 2024/6/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Track>!
    
    private var datas: [Track] = [
        Track(trackId: 1, trackName: "你好", trackTimeMillis: 123, longDescription: "你好", artworkURL100: "123", previewURL: "123"),
        Track(trackId: 2, trackName: "你好", trackTimeMillis: 123, longDescription: "你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好", artworkURL100: "123", previewURL: "123"),
        Track(trackId: 3, trackName: "你好", trackTimeMillis: 123, longDescription: "你好", artworkURL100: "123", previewURL: "123"),
        Track(trackId: 4, trackName: "你好", trackTimeMillis: 123, longDescription: "你好", artworkURL100: "123", previewURL: "123"),
        Track(trackId: 5, trackName: "你好", trackTimeMillis: 123, longDescription: "你好", artworkURL100: "123", previewURL: "123"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDataSource()
    }
    
    private func configureUI() {
        searchButton.layer.cornerRadius = 6
        searchButton.addTarget(self, action: #selector(search), for: .touchUpInside)
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        collectionView.collectionViewLayout = configureLayout()
        collectionView.register(UINib(nibName: TrackCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: TrackCell.reuseIdentifier)
    }
    
    private func configureLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(160.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
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
            
            
            return cell
        }
        collectionView.dataSource = dataSource
        var initialSnapshot = NSDiffableDataSourceSnapshot<Section, Track>()
        initialSnapshot.appendSections([.main])
        initialSnapshot.appendItems(datas)
        
        dataSource.apply(initialSnapshot, animatingDifferences: false)
    }
    
    
    @objc func search() {
        print("did tapped searchBtn")
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        print("search text: \(text)")
    }
}
