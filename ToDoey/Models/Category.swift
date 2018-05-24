//
//  Category.swift
//  ToDoey
//
//  Created by Ruurd Pels on 24-05-2018.
//  Copyright © 2018 Bureau Pels. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}
