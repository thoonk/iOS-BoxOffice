//
//  MovieData.swift
//  iOS_ProjectE
//
//  Created by 김태훈 on 2020/09/29.
//

import Foundation

/*
 {"movies":[{"date":"2017-11-22","reservation_rate":61.69,"grade":15,"thumb":"http://movie2.phinf.naver.net/20171107_251/1510033896133nWqxG_JPEG/movie_image.jpg?type=m99_141_2","reservation_grade":6,"user_rating":6.4,"id":"5a54be21e8a71d136fb536a1","title":"꾼"}
 */

struct APIResponseForMovies: Codable{
    let movies: [Movies]
}


struct Movies: Codable{
    var date: String
    var reservationRate: Double
    var grade: Int
    var thumb: String
    var reservationGrade: Int
    var userRating: Double
    var id: String
    var title: String
    
    private enum CodingKeys: String, CodingKey{
        case reservationRate = "reservation_rate"
        case reservationGrade = "reservation_grade"
        case userRating = "user_rating"
        case date, grade, thumb, id, title
    }
    
    var tableSecond: String{
        return "평점: \(self.userRating)" + " 예매순위: \(self.reservationGrade)" + " 예매율: \(self.reservationRate)"
    }
    
    var collectionSecond: String{
        return "\(reservationGrade)위(\(userRating)) / \(reservationRate)%"
    }
}

struct Movie: Codable {
    var synopsis: String
    var director: String
    var image: String
    var userRating: Double
    var duration: Int
    var audience: Int
    var date: String
    var reservationRate: Double
    var id: String
    var grade: Int
    var genre: String
    var reservationGrade: Int
    var actor: String
    var title: String
    
    private enum CodingKeys: String, CodingKey{
        case reservationRate = "reservation_rate"
        case reservationGrade = "reservation_grade"
        case userRating = "user_rating"
        case synopsis, director, image, duration, audience, date, id, grade, genre, actor, title
    }
}
