//
//  CurrentWeather.swift
//  Location
//
//  Created by 최정안 on 2/3/25.
//

import Foundation

struct CurrentWeather: Decodable {
    let main: WeatherDetail
    let wind : WindDetail
}

struct WeatherDetail: Decodable {
    let temp: Double
    let temp_min: Double
    let temp_max: Double
    let humidity: Double
}

struct WindDetail: Decodable {
    let speed : Double
}
