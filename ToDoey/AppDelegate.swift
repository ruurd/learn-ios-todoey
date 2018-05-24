//
//  AppDelegate.swift
//  ToDoey
//
//  Created by Ruurd Pels on 22-05-2018.
//  Copyright © 2018 Bureau Pels. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let config = Realm.Configuration(
            schemaVersion: 3,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 2) {
                    migration.enumerateObjects(ofType: Item.className()) { oldObject, newObject in
                        let title = oldObject!["title"] as! String
                        let done = oldObject!["done"] as! Bool
                        let crea = oldObject!["dateCreated"] as! Date

                        newObject!["title"] = title
                        newObject!["done"] = done
                        newObject!["dateCreated"] = crea
                        newObject!["dateFinished"] = Date.init(timeIntervalSince1970: 0)
                    }
                }
        })

        Realm.Configuration.defaultConfiguration = config

        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        do {
            let _ = try Realm()
        } catch {
            print("Error in Realm init: \(error)")
        }

        print(Realm.Configuration.defaultConfiguration.fileURL!)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
