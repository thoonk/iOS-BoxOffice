//
//  Request.swift
//  iOS_ProjectE
//
//  Created by 김태훈 on 2020/09/29.
//

import Foundation

enum OrderType: Int {
    case reservationRate = 0
    case curation = 1
    case date = 2
}

let DidRecieveMoviesNotification: Notification.Name = Notification.Name("DidRecieveMovies")

class Request{
    
    private enum URLType{
        case movies
        case movie
        case comments
        case post
    }
    
    static let shared = Request()
    private init() {}
    
    static var orderType: OrderType = .reservationRate
    private lazy var urlSession = URLSession.shared
    private var dataTask: [URLSessionDataTask]()
    private let baseURL = "https://connect-boxoffice.run.goorm.io"
    
    
    func requestMovies(orderType: Int){
        guard let url: URL = URL(string: "https://connect-boxoffice.run.goorm.io/movies?order_type=" + String(orderType)) else {return}
        
        let session: URLSession = URLSession(configuration: .default)
        let dataTask: URLSessionDataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            
            guard let data = data else {return}
            
            do{
                let apiResponse: APIResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                
                NotificationCenter.default.post(name: DidRecieveMoviesNotification, object: nil, userInfo: ["movies": apiResponse.movies])
                
            }catch(let err){
                print(err.localizedDescription)
            }
        }
        dataTask.resume()
    }
    
    private func createURL(_ type: URLType, parameters: [String: String]) -> URL?{
        var urlString = baseURL
        switch type{
        case .movies:
            urlString += "/movies?"
        case .movie:
            urlString += "/movie?"
        case .comments:
            urlString += "/comments?"
        case .post:
            urlString += "/comment"
            return URL(string: urlString)
        }
    }
}


