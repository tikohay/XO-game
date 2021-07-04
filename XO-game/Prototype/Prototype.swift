//
//  Prototype.swift
//  XO-game
//
//  Created by Veaceslav Chirita on 17.06.2021.
//  Copyright © 2021 plasmon. All rights reserved.
//

import Foundation

protocol Copying {
    init(_ prototype: Self)
}

extension Copying {
    func copy() -> Self {
        return type(of: self).init(self)
    }
}
