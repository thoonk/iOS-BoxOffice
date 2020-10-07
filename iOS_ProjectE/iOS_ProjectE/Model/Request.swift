//
//  Request.swift
//  iOS_ProjectE
//
//  Created by 김태훈 on 2020/09/29.
//

import Foundation

let DidRecieveMoviesNotification: Notification.Name = Notification.Name("DidRecieveMovies")
let DidRecieveMovieNotification: Notification.Name = Notification.Name("DidRecieveMovie")

// MARK: - 영화 목록 요청
func requestMovies(orderType: Int){
    guard let url: URL = URL(string: "http://connect-boxoffice.run.goorm.io/movies?order_type=\(orderType)") else {
        return
    }
    
    let session: URLSession = URLSession(configuration: .default)
    let dataTask: URLSessionDataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
        if let error = error{
            print(error.localizedDescription)
            return
        }

        guard let data = data else {return}

        do{
            let apiResponse: APIResponseForMovies = try JSONDecoder().decode(APIResponseForMovies.self, from: data)

            NotificationCenter.default.post(name: DidRecieveMoviesNotification, object: nil, userInfo: ["movies": apiResponse.movies])

        }catch(let err){
            print(err.localizedDescription)
        }
    }
    dataTask.resume()
}

func requestMovieDetail(_ id: String){
    guard let url: URL = URL(string: "http://connect-boxoffice.run.goorm.io/movie?id=\(id)") else{
        print("url error")
        return
    }
    
    let session: URLSession = URLSession(configuration: .default)
    let dataTask: URLSessionDataTask = session.dataTask(with: url) {(data: Data?, response: URLResponse?, error: Error?) in
        if let error = error{
            print(error.localizedDescription)
            return
        }
        
        guard let data = data else {return}
        
        do {
            let apiResponse = try JSONDecoder().decode(Movie.self, from: data)
            NotificationCenter.default.post(name: DidRecieveMovieNotification, object: nil, userInfo: ["movie": apiResponse])
        } catch(let err){
            print(err.localizedDescription)
        }
    }
    dataTask.resume()
}
