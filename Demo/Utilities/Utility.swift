//
//  Utility.swift
//  Demo
//
//  Created by Vaishu on 24/7/19.
//  Copyright © 2019 Vaishu. All rights reserved.
//

import Foundation
import UIKit

func dateFromString(string:String, withFormat format:String = "yyyy-MM-dd") -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    let date = dateFormatter.date(from: string)
    return date
}

