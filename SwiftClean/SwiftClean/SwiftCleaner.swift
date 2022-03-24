//
//  SwiftCleaner.swift
//  SwiftClean
//
//  Created by Elina Semenko on 04.03.2022.
//

import UIKit
import CoreData

//private enum FileTime: Double {
//    case txt = 60
//    case jpg = 30
//    case other = 120
//}

public enum TimeType {
    case ext
    case folder
}

public struct FileName: Hashable {
    public static func == (lhs: FileName, rhs: FileName) -> Bool {
        return lhs.type == rhs.type && lhs.value == rhs.value
    }
    
    var type: TimeType
    var value: String
}

public class SwiftCleaner {
    
    public var fileTimeDictionary: [FileName:Double] = [FileName(type: .ext, value: "txt"):60, FileName(type: .folder, value: "filder1/folder2"): 40]
    
    public var fileTime: [String:Double] = ["txt":60, "hello/app": 40]
    
    public init() {}
    
    let frameworkBundleID   = "com.example.SwiftClean"
    let modelName           = "FileModel"
    
    lazy var persistentContainer: NSPersistentContainer? = {
        
        let frameworkBundle = Bundle(identifier: self.frameworkBundleID)
        
        guard let modelURL = frameworkBundle?.url(forResource: self.modelName, withExtension: "momd"), let managedObjectModel =  NSManagedObjectModel(contentsOf: modelURL) else { return nil }
        
        let container = NSPersistentContainer(name: self.modelName, managedObjectModel: managedObjectModel)
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
        guard let context = persistentContainer?.viewContext else { return }
        let fetchRequest: NSFetchRequest<CleanerFile>
        fetchRequest = CleanerFile.fetchRequest()
       
        do {
            let objects = try context.fetch(fetchRequest)
            for object in objects {
                let time = getExtensionTime(path: object.place)
                let timePassed = object.created?.timeIntervalSinceNow ?? 0
                if -timePassed >= time {
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
            save([url])
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
    
//    private func getExtensionTime(path: URL?) -> FileTime {
//        guard let ext = path?.pathExtension else { return .other }
//        switch ext {
//        case "txt":
//            return .txt
//        case "jpg":
//            return .jpg
//        default:
//            return .other
//        }
//    }
    
    private func getExtensionTime(path: URL?) -> Double {
        
//        guard let ext = path?.pathExtension else { return 0 }
        
        for key in fileTime.keys {
            if path?.absoluteString.contains(key) ?? false {
                return fileTime[key] ?? 0
            }
        }
        return 0
        
        
//        for key in fileTimeDictionary.keys {
//            switch key.type {
//            case .ext:
//                if ext == key.value {
//                    return fileTimeDictionary[key] ?? 0
//                }
//            case .folder:
//                if path?.absoluteString.contains(key.value) ?? false {
//                    return fileTimeDictionary[key] ?? 0
//                }
//            }
//        }
    }
    
    private func save(_ urls: [URL]) {
        guard let context = persistentContainer?.viewContext else { return }
        for url in urls {
            let cleanerFile = CleanerFile(context: context)
            cleanerFile.place = URL(fileURLWithPath: url.path)
            cleanerFile.created = Date()
            
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
}
