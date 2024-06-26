//
//  TrackCell.swift
//  itunes-search-player
//
//  Created by Melody Lee on 2024/6/24.
//

import UIKit
import AVKit
import AVFoundation

class TrackCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: TrackCell.self)

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playStatusLabel: UILabel!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var isPlaying: Bool = false

    override func prepareForReuse() {
        super.prepareForReuse()
        deinitVideo()
        playStatusLabel.isHidden = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = 16
        playStatusLabel.isHidden = true
        // Initialization code
    }
    
    func configureVideo(url: URL) {
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = imageView.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        if let playerLayer = self.playerLayer {
            imageView.layer.addSublayer(playerLayer)
        }
    }
    
    func deinitVideo() {
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerLayer = nil
        isPlaying = false
    }
    
    func toggleStatusLabel() {
        if player != nil {
            playStatusLabel.isHidden = false
            if isPlaying {
                playStatusLabel.text = "播放中..."
            } else {
                playStatusLabel.text = "暫停中..."
            }
        } else {
            playStatusLabel.isHidden = true
        }
    }
    
    func playVideo() {
        player?.play()
        isPlaying = true
    }
    
    func stopVideo() {
        player?.pause()
        isPlaying = false
    }
}
