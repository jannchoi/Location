//
//  Date+.swift
//  Location
//
//  Created by 최정안 on 2/3/25.
//

import Foundation
extension Date {
    func nowDateToString() -> String{
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 a hh시 mm분"
        return formatter.string(from: self)
    }
}
