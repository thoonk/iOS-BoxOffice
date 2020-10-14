//
//  Request.swift
//  iOS_ProjectE
//
//  Created by 김태훈 on 2020/09/29.
//

import UIKit

// 정렬 타입
enum OrderType: Int {
    case reservationRate = 0    // 예매순
    case curation = 1           // 큐레이터
    case date = 2               // 개봉순
}

typealias completionHandler = (Bool, AnyObject?, Error?) -> Void

class Request{
    
    private enum URLType {
        case movies
        case movie
        case comments
        case post
    }

    //MARK: - Singletone
    static let shared = Request()
    private init() {}
    
    static var orderType: OrderType = .reservationRate
    private lazy var urlSession = URLSession.shared
    private var tasks = [URLSessionTask]()
    private let baseURL = "http://connect-boxoffice.run.goorm.io"
    
    // MARK: - 영화 목록 요청
    func requestMovies(_ type: OrderType, completionHandler: @escaping completionHandler){
        
        let parameter = ["order_type": "\(type.rawValue)"]
        guard let url = createURL(.movies, parameters: parameter) else {
            completionHandler(false, nil, nil)
            return
        }
        request(url, type: .movies, completionHandler: completionHandler)
    }
    
    //MARK: - 영화 상세정보 요청
    func requestMovieDetail(_ id: String, completionHandler: @escaping completionHandler){
        let parameter = ["id": "\(id)"]
        guard let url = createURL(.movie, parameters: parameter) else {
            completionHandler(false, nil, nil)
            return
        }
        request(url, type: .movie, completionHandler: completionHandler)
    }
    
    //MARK: - 영화 한줄평 목록 요청
    func requestMovieComments(_ id: String, completionHandler: @escaping completionHandler){
        let parameter = ["movie_id": "\(id)"]
        guard let url = createURL(.comments, parameters: parameter) else {
            completionHandler(false, nil, nil)
            return
        }
        request(url, type: .comments, completionHandler: completionHandler)
    }
    
    func postMovieComment(_ movieId: String, writer: String, contents: String, rating: Double, completionHandler: @escaping completionHandler){
        indicatorInMainQueue(visible: true)
        
        // 데이터 인코딩 과정
        let time = Date().timeIntervalSince1970
        let comment = WriteComment(rating: rating, writer: writer, movieId: movieId, contents: contents, timestamp: time)
        guard let uploadData = try? JSONEncoder().encode(comment), let url = createURL(.post, parameters: [:]) else{
            completionHandler(false, nil, nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        urlSession.uploadTask(with: request, from: uploadData) { [weak self] (data, response, error) in
            guard let self = self else{return}
            self.indicatorInMainQueue(visible: false)
            
            if let error = error {
                completionHandler(false, nil, error)
                return
            }
            if let  response = response as? HTTPURLResponse {
                if (200 ... 299).contains(response.statusCode) {
                    completionHandler(true, nil, nil)
                } else {
                    let error = NSError(domain: "", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey : "Server error"])
                    completionHandler(false, nil, error)
                }
            }
        }.resume()
    }
    
    //MARK: - 요청 처리
    private func request(_ url: URL, type: URLType, completionHandler: @escaping completionHandler) {
        indicatorInMainQueue(visible: true)
        urlSession.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            self.indicatorInMainQueue(visible: false)
            if let error = error {
                completionHandler(false, nil, error)
                return
            }
            guard let data = data else {
                completionHandler(false, nil, nil)
                return
            }
            do {
                switch type {
                case .movies:
                    let apiResponse = try JSONDecoder().decode(APIResponseForMovies.self, from: data)
                    completionHandler(true, apiResponse.movies as AnyObject, nil)
                case .movie:
                    let apiResponse = try JSONDecoder().decode(Movie.self, from: data)
                    completionHandler(true, apiResponse as AnyObject, nil)
                case .comments:
                    let apiResponse = try JSONDecoder().decode(APIResponseForComments.self, from: data)
                    completionHandler(true, apiResponse.comments as AnyObject, nil)
                default:
                    ()
                }
            } catch let error {
                completionHandler(false, nil, error)
            }
        }.resume()
    }
    
    //MARK: - URL 생성
    private func createURL(_ type: URLType, parameters: [String: String]) -> URL? {
        var urlString = baseURL
        switch type {
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
        let zippedParameters = zip(parameters.keys, parameters.keys.map { parameters[$0] })
        let parametersString = zippedParameters.map { "\($0)=\($1 ?? "")"}.joined(separator: "&")
        urlString += parametersString
        return URL(string: urlString)
    }

    //MARK: - IndicatorView
    private func indicatorInMainQueue(visible: Bool) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = visible
        }
    }
    
}
