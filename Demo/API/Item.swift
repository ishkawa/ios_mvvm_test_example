//
//  Repository.swift
//  Demo
//
//  Created by Yosuke Ishikawa on 2019/01/14.
//  Copyright © 2019 Yosuke Ishikawa. All rights reserved.
//

import Foundation

struct Repository: Equatable, Mutatable {
    var id: Int64
    var name: String
    var description: String
    var isStarred: Bool
}
