//
//  ViewController.swift
//  itunes-search-player
//
//  Created by Melody Lee on 2024/6/24.
//

import UIKit
import Kingfisher
import RxSwift
import RxCocoa

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
    private let disposeBag = DisposeBag()
    
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
    }
    
    // MARK: - Datas
    private func bindingViewModel() {
        searchTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .skip(1)
            .subscribe { [weak self] text in
                self?.viewModel.fetchDatas(text: text)
            }.disposed(by: disposeBag)
        
        viewModel.tracks
            .skip(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] tracks in
                self?.playingCell?.stopVideo()
                self?.updateDatas(tracks: tracks)
            }).disposed(by: disposeBag)
        
        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                print("Error received: \(error.localizedDescription)")
                self?.showErrorAlert(error: error)
            }).disposed(by: disposeBag)
    }
    
    private func updateDatas(tracks: [Track]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Track>()
        snapshot.appendSections([.main])
        snapshot.appendItems(tracks)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func getformattedTime(millis: Int) -> String {
        let timestamp: TimeInterval = Double(millis) / 1000.0
        let date = Date(timeIntervalSince1970: timestamp)
        let formattedTime = formatter.string(from: date)
        return formattedTime
    }
    
    private func showErrorAlert(error: SearchError) {
        let alert = UIAlertController(title: "Error", message: "oops! There is an \(error.errorMessage) occurred!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    // MARK: - Interactions
    @objc func search() {
        print("did tapped searchBtn")
        guard let text = searchTextField.text else { return }
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
              let urlString = try? viewModel.tracks.value()[indexPath.row].previewUrl,
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
