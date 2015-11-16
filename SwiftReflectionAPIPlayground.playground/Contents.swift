//: Playground - noun: a place where people can play

import Foundation
import CoreData

public class Store {
    let storesToDisk: Bool = true
}
public class BookmarkStore: Store {
    let itemCount: Int = 10
}
public struct Bookmark {
    enum Group {
        case Tech
        case News
    }
    private let store = {
        return BookmarkStore()
    }()
    let title: String?
    let url: NSURL
    let keywords: [String]
    let group: Group
    let pagerank: Int
    let created: NSDate
}

let aBookmark = Bookmark(title: "Appventure", url: NSURL(string: "appventure.me")!, keywords: ["Swift", "iOS", "OSX"], group: .Tech, pagerank:10, created:NSDate())
print(aBookmark)



let aMirror = Mirror(reflecting: aBookmark)
print(aMirror)
// 输出 : Mirror for Bookmark



//public enum DisplayStyle {
//    case Struct
//    case Class
//    case Enum
//    case Tuple
//    case Optional
//    case Collection
//    case Dictionary
//    case Set
//}



let closure = { (a: Int) -> Int in return a * 2 }
let bMirror = Mirror(reflecting: closure)



public typealias Child = (label: String?, value: Any)



//public enum AncestorRepresentation {
//    /// 为所有 ancestor class 生成默认 mirror。
//    case Generated
//    /// 使用最近的 ancestor 的 customMirror() 实现来给它创建一个 mirror。
//    case Customized(() -> Mirror)
//    /// 禁用所有 ancestor class 的行为。Mirror 的 superclassMirror() 返回值为 nil。
//    case Suppressed
//}



print (aMirror.displayStyle)
// 输出: Optional(Swift.Mirror.DisplayStyle.Struct)



for case let (label?, value) in aMirror.children {
    print (label, value)
}



print(aMirror.subjectType)
//输出 : Bookmark
print(Mirror(reflecting: 5).subjectType)
//输出 : Int
print(Mirror(reflecting: "test").subjectType)
//输出 : String
print(Mirror(reflecting: NSNull()).subjectType)
//输出 : NSNull



// 试试 struct
print(Mirror(reflecting: aBookmark).superclassMirror())
// 输出: nil
// 试试 class
print(Mirror(reflecting: aBookmark.store).superclassMirror())
// 输出: Optional(Mirror for Store)



protocol StructDecoder {
    // 我们 Core Data 实体的名字
    static var EntityName: String { get }
    // 返回包含我们属性集的 NSManagedObject
    func toCoreData(context: NSManagedObjectContext) throws -> NSManagedObject
}



enum SerializationError: ErrorType {
    // 我们只支持 struct
    case StructRequired
    // 实体在 Core Data 模型中不存在
    case UnknownEntity(name: String)
    // 给定的类型不能保存在 core data 中
    case UnsupportedSubType(label: String?)
}



struct SecBookmark {
    let title: String
    let url: NSURL
    let pagerank: Int
    let created: NSDate
}



extension StructDecoder {
    func toCoreData(context: NSManagedObjectContext) throws -> NSManagedObject {
        let entityName = self.dynamicType.EntityName
        
        // Create the Entity Description
        guard let desc = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)
            else { throw SerializationError.UnknownEntity(name: entityName) }
        
        // Create the NSManagedObject
        let managedObject = NSManagedObject(entity: desc, insertIntoManagedObjectContext: context)
        
        // Create a Mirror
        let mirror = Mirror(reflecting: self)
        
        // Make sure we're analyzing a struct
        guard mirror.displayStyle == .Struct else { throw SerializationError.StructRequired }
        
        for case let (label?, anyValue) in mirror.children {
            if let value = anyValue as? AnyObject {
                managedObject.setValue(value, forKey: label)
            } else {
                throw SerializationError.UnsupportedSubType(label: label)
            }
        }
        
        return managedObject
    }
}

extension Bookmark: CustomReflectable {
    public func customMirror() -> Mirror {
        let children = DictionaryLiteral<String, Any>(dictionaryLiteral:
            ("title", self.title), ("pagerank", self.pagerank),
            ("url", self.url), ("created", self.created),
            ("keywords", self.keywords), ("group", self.group))
        
        return Mirror.init(Bookmark.self, children: children,
            displayStyle: Mirror.DisplayStyle.Struct,
            ancestorRepresentation:.Suppressed)
    }
}
