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
    
    var viewModel = TrackListViewModel()
    private var dataSource: UICollectionViewDiffableDataSource<Section, Track>!
    
    private var playingCell: TrackCell?
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDataSource()
        bindingViewModel()
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
    private func bindingViewModel() {
        viewModel.onError = { error in
            print("vc recieve error: \(error.localizedDescription)")
        }
        viewModel.onReceiveTracks = {
            self.updateDatas()
        }
        
    }
    
    private func updateDatas() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Track>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.tracks)
        dataSource.apply(snapshot, animatingDifferences: true)
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
        viewModel.fetchDatas(text: text)
    }
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
              let urlString = viewModel.tracks[indexPath.row].previewUrl,
//              let urlString = datas[indexPath.row].previewUrl,
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
