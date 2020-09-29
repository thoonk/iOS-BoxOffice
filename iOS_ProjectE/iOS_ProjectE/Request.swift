//
//  Request.swift
//  iOS_ProjectE
//
//  Created by 김태훈 on 2020/09/29.
//

import Foundation

let DidRecieveMoviesNotification: Notification.Name = Notification.Name("DidRecieveMovies")

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
