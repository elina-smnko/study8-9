//
//  SwiftCleaner.swift
//  SwiftClean
//
//  Created by Elina Semenko on 04.03.2022.
//

import UIKit
import CoreData

private enum FileTime: Double {
    case txt = 60
    case jpg = 30
    case other = 120
}

public class SwiftCleaner {
    
    public init() {}
    
    let frameworkBundleID   = "com.example.SwiftClean"
    let modelName           = "FileModel"
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let frameworkBundle = Bundle(identifier: self.frameworkBundleID)
        let modelURL = frameworkBundle!.url(forResource: self.modelName, withExtension: "momd")!
        let managedObjectModel =  NSManagedObjectModel(contentsOf: modelURL)
        
        let container = NSPersistentContainer(name: self.modelName, managedObjectModel: managedObjectModel!)
        container.loadPersistentStores { storeDescription, error in
            
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        
        return container
    }()
    
    let fileManager = FileManager.default
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    public func check() {
        let fetchRequest: NSFetchRequest<CleanerFile>
        fetchRequest = CleanerFile.fetchRequest()
        let context = persistentContainer.viewContext
        
        do {
            let objects = try context.fetch(fetchRequest)
            for object in objects {
                let time = getExtensionTime(path: object.place)
                let timePassed = object.created?.timeIntervalSinceNow ?? 0
                if -timePassed >= time.rawValue {
                    remove(file: object.place!)
                    context.delete(object)
                    try context.save()
                }
            }
        }
        catch {
            print("fetch error")
        }
    }
    
    public func addItem() {
        let str = "Test Message"
        let url = documentsURL.appendingPathComponent("message1.txt")
        
        do {
            try str.write(to: url, atomically: true, encoding: .utf8)
            print("url")
            save([url])
            print(url)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func remove(file: URL?) {
        guard let file = file else { return }
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: file)
            print("Removed file: \(file.path)")
        } catch {
            print("Could not remove file: \(error)")
        }
    }
    
    private func getExtensionTime(path: URL?) -> FileTime {
        guard let ext = path?.pathExtension else { return .other }
        switch ext {
        case "txt":
            return .txt
        case "jpg":
            return .jpg
        default:
            return .other
        }
    }
    
    private func save(_ urls: [URL]) {
        for url in urls {
            let cleanerFile = CleanerFile(context: persistentContainer.viewContext)
            cleanerFile.place = URL(fileURLWithPath: url.path)
            cleanerFile.created = Date()
            
            do {
                try persistentContainer.viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
}
