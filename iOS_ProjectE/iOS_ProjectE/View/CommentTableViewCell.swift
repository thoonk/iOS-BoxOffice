//
//  CommentTableViewCell.swift
//  iOS_ProjectE
//
//  Created by 김태훈 on 2020/10/05.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var writerImageView: UIImageView!
    @IBOutlet weak var writerLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var starRatingView: StarRatingView!{
        didSet{
            starRatingView.isEditable = false
            starRatingView.maxRating = 10
            starRatingView.emptyImage = UIImage(named: "ic_star_large")
            starRatingView.halfImage = UIImage(named: "ic_star_large_half")
            starRatingView.fullImage = UIImage(named: "ic_star_large_full")
        }
    }
    
    private lazy var dateFormmater: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        return formatter
    }()
    
    func mappingData(_ data: Comment){
        writerImageView.image = UIImage(named: "ic_user_loading")
        writerLabel.text = data.writer
        reviewLabel.text = data.contents
        if let time = data.timestamp {
            let date = Date(timeIntervalSince1970: time)
            timeLabel.text = dateFormmater.string(from: date)
        }
        starRatingView.currentRating = data.rating
    }
}
