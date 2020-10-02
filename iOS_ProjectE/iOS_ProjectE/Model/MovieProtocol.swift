//
//  MovieProtocol.swift
//  iOS_ProjectE
//
//  Created by 김태훈 on 2020/10/02.
//

import UIKit

protocol MovieProtocol: MovieRequest, MovieOrderRequest, MovieUI { }

protocol MovieRequest{
    var request: Request {get}
}

extension MovieRequest{
    var request: Request{
        return Request.shared
    }
}

protocol MovieOrderRequest{
    func registerOrderType()
    func didReceiveNotification(_ notification: Notification)
}

protocol MovieUI {
    func setGradeImageView(_ imageView: UIImageView, grade: Int)
    func setOrderType()
}

extension MovieUI{
    func setGradeImageView(_ imageView: UIImageView, grade: Int){
        if grade == 0{
            imageView.image = UIImage(named: "ic_allages")
        } else if grade == 12{
            imageView.image = UIImage(named: "ic_12")
        } else if grade == 15 {
            imageView.image = UIImage(named: "ic_15")
        } else {
            imageView.image = UIImage(named: "ic_19")
        }
    }
    func setOrderType() {}
}
