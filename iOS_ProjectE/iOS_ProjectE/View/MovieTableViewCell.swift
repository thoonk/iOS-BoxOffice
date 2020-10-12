//
//  MovieTableViewCell.swift
//  iOS_ProjectE
//
//  Created by 김태훈 on 2020/09/29.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var gradeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func mappingData(_ data: Movies){
        thumbImageView.image = nil
        titleLabel.text = data.title
        detailLabel.text = data.tableSecond
        dateLabel.text = "개봉일: \(data.date)"
    }
}
