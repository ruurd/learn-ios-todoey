//
//  Item.swift
//  ToDoey
//
//  Created by Ruurd Pels on 24-05-2018.
//  Copyright © 2018 Bureau Pels. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date = Date()
    @objc dynamic var dateFinished: Date = Date.init(timeIntervalSince1970: 0)
}
