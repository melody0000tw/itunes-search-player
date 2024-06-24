//
//  TrackCell.swift
//  itunes-search-player
//
//  Created by Melody Lee on 2024/6/24.
//

import UIKit

class TrackCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: TrackCell.self)

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playStatusLabel: UILabel!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = 16
        // Initialization code
    }

}
