//
//  Request.swift
//  Networking
//
//  Created by 김태훈 on 2020/09/29.
//

import Foundation

let DidReceiveFriendsNotification: Notification.Name = Notification.Name("DidRecieveFriends")

func requestFriends(){
    
    guard let url: URL = URL(string: "https://randomuser.me/api/?results=20&inc=name,email,picture") else {return}
    
    let session: URLSession = URLSession(configuration: .default)
    let dataTask: URLSessionDataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in // 요청에 대한 서버의 응답이 왔을 때 호출될 클로저 // background에서 수행
        if let error = error{
            print(error.localizedDescription)
            return
        }
        guard let data = data else {return}
        
        do{
            let apiResponse: APIResponse = try JSONDecoder().decode(APIResponse.self, from: data)
            
            NotificationCenter.default.post(name: DidReceiveFriendsNotification, object: nil, userInfo: ["friends":apiResponse.results])
            
            
        } catch(let err){
            print(err.localizedDescription)
        }
    }
    dataTask.resume()
}
