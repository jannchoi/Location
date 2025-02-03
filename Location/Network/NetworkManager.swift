//
//  NetworkManager.swift
//  Location
//
//  Created by 최정안 on 2/3/25.
//

import Foundation
import Alamofire

enum weatherRequest {
    case currentWeather(lat: Double, lon: Double)
    var baseURL: String {
        return "https://api.openweathermap.org/data/2.5/weather?"
    }
    
    var endpoint: URL {
        switch self {
        case .currentWeather(let lat, let lon) :
            return URL(string: baseURL + "lat=\(lat)&lon=\(lon)&appid=\(APIKey.key)&lang=kr&units=metric")!
        }
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    private init() { }
    
    func callRequest<T: Decodable>(api: weatherRequest,type: T.Type, completionHandler: @escaping (Result<T,Error>) -> Void) {
        AF.request(api.endpoint)
            .validate(statusCode: 200...200)
            .responseDecodable(of: T.self) { response in
                switch response.result {
                    
                case .success(let value):
                    completionHandler(.success(value))
                case .failure(let error):
                    let code = response.response?.statusCode
                    completionHandler(.failure(self.defineError(code: code ?? 500)))
                    print(error)
                }
            }
    }
    
    private func defineError(code: Int) -> NetworkError{
        switch code {
        case 401: return .keyError
        case 404: return .requestError
        case 429: return .exceedCall
        default : return .otherError
        }
    }
}
