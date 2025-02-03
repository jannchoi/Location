//
//  NetworkError.swift
//  Location
//
//  Created by 최정안 on 2/3/25.
//

import Foundation

enum NetworkError: Error {
    case keyError
    case requestError
    case exceedCall
    case otherError
    
    var errorMessage: String{
        switch self {
            
        case .keyError:
            return "APIKey Error"
        case .requestError:
            return "Wrong request"
        case .exceedCall:
            return "Exceed the limit of calls"
        case .otherError:
            return "Something wrong.."
        }
    }
}
