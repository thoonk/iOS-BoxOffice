//
//  Movie.swift
//  iOS_ProjectE
//
//  Created by 김태훈 on 2020/09/29.
//

import Foundation

/*
 {"movies":[{"date":"2017-11-22","reservation_rate":61.69,"grade":15,"thumb":"http://movie2.phinf.naver.net/20171107_251/1510033896133nWqxG_JPEG/movie_image.jpg?type=m99_141_2","reservation_grade":6,"user_rating":6.4,"id":"5a54be21e8a71d136fb536a1","title":"꾼"}
 */

struct APIResponse: Codable{
    let movies: [Movie]
}

struct Movie: Codable{
    let date: String
    let reservation_rate: Double
    let grade: Int
    let thumb: String
    let reservation_grade: Int
    let user_rating: Double
    let id: String
    let title: String
    
    var tableSecond: String{
        return "평점: \(self.user_rating)" + " 예매순위: \(self.user_rating)" + " 예매율: \(self.reservation_rate)"  
    }
    
    var collectionSecond: String{
        return "\(reservation_grade)위(\(user_rating)) / \(reservation_rate)%"
    }
    
}
