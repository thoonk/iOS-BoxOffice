//
//  ExtensionArray.swift
//  iOS_ProjectE
//
//  Created by 김태훈 on 2020/10/06.
//

import Foundation

extension Array {
    /// 안전한 인덱스 접근.
    subscript(safeIndex index: Int) -> Element? {
        if indices.contains(index) {
            return self[index]
        }
        return nil
    }
}
