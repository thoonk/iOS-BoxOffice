//
//  MovieProtocol.swift
//  iOS_ProjectE
//
//  Created by 김태훈 on 2020/10/12.
//

import UIKit

protocol MovieProtocol: MovieRequest, MovieOrderRequest, MovieUI { }

protocol MovieRequest {
    var request: Request { get }
    func errorHandler(_ errorR : Error?, completionHandler: (() -> Void)?)
}

extension MovieRequest{
    var request: Request {
        return Request.shared
    }
}

protocol MovieOrderRequest {
    // 노티피케이션 등록
    func registerOrderTypeNotification()
    // 노티피케이션 처리
    func didReceiveNotification(_ notification: Notification)
}

protocol MovieUI {
    // 등급에 따라 이미지를 변경
    func setGradeImageView(_ imageView: UIImageView, grade: Int)
    // 인디케이터 동작.
    func indicatorViewAnimating(_ indicatorView: UIActivityIndicatorView, isStart: Bool)
    // 인디케이터 동작.
    func indicatorViewAnimating(_ indicatorView: UIActivityIndicatorView, refresher: UIRefreshControl, isStart: Bool)
    // 정렬 타입을 선택하는 액션시트
    func setOrderType()
}

extension MovieUI{
    func setGradeImageView(_ imageView: UIImageView, grade: Int) {
        if grade == 0 {
            imageView.image = UIImage(named: "ic_allages")
        } else if grade == 12 {
            imageView.image = UIImage(named: "ic_12")
        } else if grade == 15 {
            imageView.image = UIImage(named: "ic_15")
        } else {
            imageView.image = UIImage(named: "ic_19")
        }
    }
    func indicatorViewAnimating(_ indicatorView: UIActivityIndicatorView, isStart: Bool) {}
    func indicatorViewAnimating(_ indicatorView: UIActivityIndicatorView, refresher: UIRefreshControl, isStart: Bool) {}
    func setOrderType() {}
}

class MovieViewController: UIViewController, MovieProtocol{
    
    //MARK: - MovieRequest Protocol
    func errorHandler(_ error: Error? = nil, completionHandler: (() -> Void)? = nil) {
        let message: String
        if let error = error {
            message = "네트워크 오류: \(error.localizedDescription)"
        } else {
            message = "네트워크 오류가 발생하였습니다."
        }
        alert(message) {
            completionHandler?()
        }
    }
    
    func registerOrderTypeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(_:)), name: .changeOrderType, object: nil)
    }
    @objc func didReceiveNotification(_ notification: Notification) {
        guard let orderType = notification.userInfo?["orderType"] as? OrderType else {
            return
        }
        Request.orderType = orderType
    }
    
    //MARK: - MovieUI Protocol
    func indicatorViewAnimating(_ indicatorView: UIActivityIndicatorView, isStart: Bool) {
        if isStart {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.view.bringSubviewToFront(indicatorView)
                indicatorView.isHidden = false
                indicatorView.startAnimating()
            }
        } else {
            DispatchQueue.main.async {
                indicatorView.stopAnimating()
                indicatorView.isHidden = true
            }
        }
    }
    
    func indicatorViewAnimating(_ indicatorView: UIActivityIndicatorView, refresher: UIRefreshControl, isStart: Bool) {
        if isStart {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.view.bringSubviewToFront(indicatorView)
                indicatorView.isHidden = false
                indicatorView.startAnimating()
            }
        } else {
            DispatchQueue.main.async {
                indicatorView.stopAnimating()
                indicatorView.isHidden = true
                if refresher.isRefreshing {
                    refresher.perform(#selector(refresher.endRefreshing), with: nil, afterDelay: 0.00)
                }
            }
        }
    }

    func setOrderType() {
        // 메인 스레드에서 실행
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let actionSheet = UIAlertController(title: "정렬방식 선택", message: "어떤 순서로 정렬할까요?", preferredStyle: .actionSheet)
            let reservationRateAction = UIAlertAction(title: "예매율", style: .default) { (_) in
                NotificationCenter.default.post(name: .changeOrderType, object: nil, userInfo: ["orderType": OrderType.reservationRate])
            }
            let currationAction = UIAlertAction(title: "큐레이션", style: .default) { (_) in
                NotificationCenter.default.post(name: .changeOrderType, object: nil, userInfo: ["orderType": OrderType.curation])
            }
            let dateAction = UIAlertAction(title: "개봉일", style: .default) { (_) in
                NotificationCenter.default.post(name: .changeOrderType, object: nil, userInfo: ["orderType": OrderType.date])
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            actionSheet.addAction(reservationRateAction)
            actionSheet.addAction(currationAction)
            actionSheet.addAction(dateAction)
            actionSheet.addAction(cancelAction)
            self.present(actionSheet, animated: true)
        }
    }
}

extension MovieViewController{
    // Alert Action
    func alert(_ message: String, completionHandler: (() -> Void)? = nil) {
        // 메인 스레드에서 실행
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .cancel) { (_) in
                completionHandler?() // completionHandler 매개변수의 값이 nil이 아닐 때에만 실행되도록
            }
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
    }
}

extension Notification.Name{
    static let changeOrderType = Notification.Name("changeOrderType")
}
