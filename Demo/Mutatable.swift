//
//  Mutatable.swift
//  Demo
//
//  Created by Yosuke Ishikawa on 2019/01/14.
//  Copyright © 2019 Yosuke Ishikawa. All rights reserved.
//

protocol Mutatable {}

extension Mutatable {
    func mutated(mutator: (inout Self) -> Void) -> Self {
        var newValue = self
        mutator(&newValue)
        return newValue
    }
}
