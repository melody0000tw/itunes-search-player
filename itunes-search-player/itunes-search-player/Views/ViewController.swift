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
    
    private var datas: [Track] = [
        Track(trackId: 1, trackName: "你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好", trackTimeMillis: 123, longDescription: "你好", artworkURL100: "https://is1-ssl.mzstatic.com/image/thumb/Video123/v4/1f/2b/ae/1f2bae7f-62a1-1055-8471-401291b6dcdd/pr_source.lsr/100x100bb.jpg", previewURL: "123"),
        Track(trackId: 2, trackName: "你好", trackTimeMillis: 123, longDescription: "你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好", artworkURL100: "https://is1-ssl.mzstatic.com/image/thumb/Video125/v4/21/0b/4a/210b4a1c-0de6-3a03-27a5-408948f7f173/pr_source.lsr/100x100bb.jpg", previewURL: "123"),
        Track(trackId: 3, trackName: "你好你好你好", trackTimeMillis: 123, longDescription: nil, artworkURL100: "https://is1-ssl.mzstatic.com/image/thumb/Music3/v4/13/60/53/1360536d-30c1-b71b-fac6-0b649b76b31c/859713193161_cover.tif/100x100bb.jpg", previewURL: "123"),
        Track(trackId: 4, trackName: "你好", trackTimeMillis: 123, longDescription: "你好", artworkURL100: "https://is1-ssl.mzstatic.com/image/thumb/Music3/v4/13/60/53/1360536d-30c1-b71b-fac6-0b649b76b31c/859713193161_cover.tif/100x100bb.jpg", previewURL: "123"),
        Track(trackId: 5, trackName: "你好", trackTimeMillis: 123, longDescription: "你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好", artworkURL100: "https://is1-ssl.mzstatic.com/image/thumb/Music3/v4/13/60/53/1360536d-30c1-b71b-fac6-0b649b76b31c/859713193161_cover.tif/100x100bb.jpg", previewURL: "123"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDataSource()
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
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
            cell.imageView.kf.setImage(with: URL(string: track.artworkURL100!))
            
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
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
