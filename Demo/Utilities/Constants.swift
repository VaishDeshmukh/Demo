//
//  Constants.swift
//  Demo
//
//  Created by Vaishu on 17/7/19.
//  Copyright © 2019 Vaishu. All rights reserved.
//

import Foundation



struct Constants {
    static let apiKey = "2759736974789ab8e9bac43e20ce3ffd"
    static let api = "?api_key=2759736974789ab8e9bac43e20ce3ffd"
    static let baseURL = "https://api.themoviedb.org/3/"
    static let authenticationURL = baseURL + "authentication/"
    static let moviesURL = baseURL + "movie/"
    static let domainData = "Data"
    static let domainCode404 = 3 // ALamofire.AFError with 404 response
    static let errorJSONParsingDescription = "Failed to parse JSON while conversion"
    static let defaultPageSize = 10
    static let imageBaseUrl = "https://image.tmdb.org/t/p/original"
}

func composeError(domain: String, code: Int, message: String) -> NSError {
    return NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey:message])
}

extension String {
    func toDate(withFormat format: String = "yyyy-MM-dd") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        guard let date = dateFormatter.date(from: self) else {
            preconditionFailure("Take a look to your format")
        }
        return date
    }
}


