//
//  UILabel+.swift
//  Location
//
//  Created by 최정안 on 2/3/25.
//

import UIKit

extension UILabel {
    func setWeatherInfo(temp: Double, temp_min: Double, temp_max: Double, hum: Double, speed: Double) {
        font = UIFont.systemFont(ofSize: 14)
        text = """
\(Date().nowDateToString())
현재 온도: \(temp)°C
최저 온도: \(temp_min)°C
최고 온도: \(temp_max)°C
습도: \(hum)%
풍속: \(speed)m/s
"""
    }
}
