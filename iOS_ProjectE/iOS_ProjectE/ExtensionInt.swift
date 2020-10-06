//
//  ExtensionInt.swift
//  iOS_ProjectE
//
//  Created by 김태훈 on 2020/10/05.
//

import Foundation

extension Int {
    // Int 타입 변수를 문자열로 변환하고 천단위로 ','를 삽입함
    func toStringWithComma() -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        if let str = numberFormatter.string(from: NSNumber(integerLiteral: self)) {
            return str
        }
        return nil
    }
}
