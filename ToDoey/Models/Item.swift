//
//  Item.swift
//  ToDoey
//
//  Created by Ruurd Pels on 22-05-2018.
//  Copyright © 2018 Bureau Pels. All rights reserved.
//

import Foundation

class Item: Encodable {
    var title: String = ""
    var done: Bool = false

    init() {}
    convenience init(title: String) {
        self.init()
        self.title = title
    }
}
