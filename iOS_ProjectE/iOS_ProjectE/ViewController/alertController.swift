//
//  alertController.swift
//  iOS_ProjectE
//
//  Created by 김태훈 on 2020/09/30.
//

import Foundation
import UIKit


let viewControllers: [UIViewController] = [TableViewController(), CollectionViewController()]

func selectOrder(controller: UIViewController){
    let alertController: UIAlertController = UIAlertController(title: "정렬방식 선택", message: "영화를 어떤 순서로 정렬할까요?", preferredStyle: .actionSheet)
    
    let reservationRateAction: UIAlertAction = UIAlertAction(title: "예매율", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction) in requestMovies(orderType: 0)
        for viewController in viewControllers{
            viewController.navigationItem.title = "예매율"
        }
        controller.navigationItem.title = "예매율"
    })
    
    let curationAction: UIAlertAction = UIAlertAction(title: "큐레이션", style: .default, handler: {(action: UIAlertAction) in requestMovies(orderType: 1)
        controller.navigationItem.title = "큐레이션"
    })
    
    let releaseDateAction: UIAlertAction = UIAlertAction(title: "개봉일", style: .default, handler: {(action: UIAlertAction) in requestMovies(orderType: 2)
        controller.navigationItem.title = "개봉일"
    })
    
    let cancelAction: UIAlertAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
    
    alertController.addAction(reservationRateAction)
    alertController.addAction(curationAction)
    alertController.addAction(releaseDateAction)
    alertController.addAction(cancelAction)
    
    controller.present(alertController, animated: true, completion: nil)
}
