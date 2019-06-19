//
//  Hero.swift
//  SqlLiteDbSample
//
//  Created by Yash on 2019-06-05.
//  Copyright © 2019 YashShah. All rights reserved.
//

import Foundation

class Hero {
    
    var id: Int
    var name: String?
    var powerRanking: Int
    
    init(id: Int, name: String?, powerRanking: Int){
        self.id = id
        self.name = name
        self.powerRanking = powerRanking
    }
}
