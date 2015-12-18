//: Playground - noun: a place where people can play

import UIKit

var animation:CAAnimation = CAAnimation()

animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)

extension CAMediaTimingFunction
{
    // 这个属性会在第一次被访问时初始化。
    // (需要添加 @nonobjc 来防止编译器
    //  给 static（或者 final）属性生成动态存取器。)
    @nonobjc static let EaseInEaseOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    
    // 另外一个选择就是使用计算属性, 它同样很有效,
    // 但 *每次* 被访问时都会重新求值：
//    static var EaseInEaseOut: CAMediaTimingFunction {
//        // .init is short for self.init
//        return .init(name: kCAMediaTimingFunctionEaseInEaseOut)
//    }
}

animation.timingFunction = .EaseInEaseOut



//////////////////////////////////////////////////////////


CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(),
    CGColorCreate(CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB), [0.792, 0.792, 0.816, 1]))

extension CGContext
{
    static func currentContext() -> CGContext? {
        return UIGraphicsGetCurrentContext()
    }
}

extension CGColorSpace
{
    static let GenericRGB = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB)
}

CGContextSetFillColorWithColor(.currentContext(),
    CGColorCreate(.GenericRGB, [0.792, 0.792, 0.816, 1]))


//////////////////////////////////////////////////////////

var label = UILabel()
var button = UIButton()

var spaceConstraint = NSLayoutConstraint(
    item: label,
    attribute: .Leading,
    relatedBy: .Equal,
    toItem: button,
    attribute: .Trailing,
    multiplier: 1, constant: 20)
var widthConstraint = NSLayoutConstraint(
    item: label,
    attribute: .Width,
    relatedBy: .LessThanOrEqual,
    toItem: nil,
    attribute: .NotAnAttribute,
    multiplier: 0, constant: 200)

//spaceConstraint.active = true
//widthConstraint.active = true

spaceConstraint = label.leadingAnchor.constraintEqualToAnchor(button.trailingAnchor, constant: 20)
widthConstraint = label.widthAnchor.constraintLessThanOrEqualToConstant(200)
//spaceConstraint.active = true
//widthConstraint.active = true

extension UIView
{
    func constrain(
        attribute: NSLayoutAttribute,
        _ relation: NSLayoutRelation,
        to otherView: UIView,
        _ otherAttribute: NSLayoutAttribute,
        times multiplier: CGFloat = 1,
        plus constant: CGFloat = 0,
        atPriority priority: UILayoutPriority = UILayoutPriorityRequired,
        identifier: String? = nil)
        -> NSLayoutConstraint
    {
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: attribute,
            relatedBy: relation,
            toItem: otherView,
            attribute: otherAttribute,
            multiplier: multiplier,
            constant: constant)
        constraint.priority = priority
        constraint.identifier = identifier
        constraint.active = true
        return constraint
    }
    
    func constrain(
        attribute: NSLayoutAttribute,
        _ relation: NSLayoutRelation,
        to constant: CGFloat,
        atPriority priority: UILayoutPriority = UILayoutPriorityRequired,
        identifier: String? = nil)
        -> NSLayoutConstraint
    {
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: attribute,
            relatedBy: relation,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 0,
            constant: constant)
        constraint.priority = priority
        constraint.identifier = identifier
        constraint.active = true
        return constraint
    }
}


//spaceConstraint = label.constrain(.Leading, .Equal, to: button, .Trailing, plus: 20)
//widthConstraint = label.constrain(.Width, .LessThanOrEqual, to: 200)



///////////////////////////////////////////////////////

let container = UIView()
let touch = UIGestureRecognizer()
let object = UIView()

let touchPos = touch.locationInView(container)
let objectOffset = CGPoint(x: object.center.x - touchPos.x, y: object.center.y - touchPos.y)


func -(lhs: CGPoint, rhs: CGPoint) -> CGVector
{
    return CGVector(dx: lhs.x - rhs.x, dy: lhs.y - rhs.y)
}

func +(lhs: CGPoint, rhs: CGVector) -> CGPoint
{
    return CGPoint(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy)
}

// 触摸开始:
let objectOffsetVector = object.center - touch.locationInView(container)

// 触摸移动:
object.center = touch.locationInView(container) + objectOffsetVector


///////////////////////////////////////////////////////



infix operator ??= { associativity right precedence 90 assignment } // 匹配其它的赋值操作符

/// 如果 `lhs` 为 `nil`, 把 `rhs` 的值赋给它
func ??=<T>(inout lhs: T?, @autoclosure rhs: () -> T)
{
    lhs = lhs ?? rhs()
}

var a:UIView?
let b = UIView()
a ??= b   // 等价于 "a = a ?? b"

///////////////////////////////////////////////////////


extension dispatch_queue_t
{
    final func async(block: dispatch_block_t) {
        dispatch_async(self, block)
    }
    
    // 这里的 `block` 需要是 @noescape 的, 但不能是链接中这样的： <http://openradar.me/19770770>
    final func sync(block: dispatch_block_t) {
        dispatch_sync(self, block)
    }
}

let mySerialQueue = dispatch_get_main_queue()

var threadsafeNum = 0

mySerialQueue.sync {
    print("I’m on the queue!")
    threadsafeNum++
}

print(threadsafeNum)

extension dispatch_queue_t
{
    final func sync<Result>(block: () -> Result) -> Result {
        var result: Result?
        dispatch_sync(self) {
            result = block()
        }
        return result!
    }
}

dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0).async {
//    expensivelyReticulateSplines()
    print("Done!")
    
    dispatch_get_main_queue().async {
        print("Back on the main queue.")
    }
}


// 在串行队列上抓取一些数据
let currentItems = mySerialQueue.sync {
    print("I’m on the queue!")
//    return mutableItems.copy()
}


extension dispatch_queue_t
{
    final func async(group: dispatch_group_t, _ block: dispatch_block_t) {
        dispatch_group_async(group, self, block)
    }
}

extension dispatch_group_t
{
    final func waitForever() {
        dispatch_group_wait(self, DISPATCH_TIME_FOREVER)
    }
}


let concurrentQueue = dispatch_get_main_queue()
let group = dispatch_group_create()

concurrentQueue.async(group) {
    print("I’m part of the group")
}

concurrentQueue.async(group) {
    print("I’m independent, but part of the same group")
}

group.waitForever()

print("Everything in the group has now executed")


///////////////////////////////////////////////////////


public class MyClass: NSObject
{
    public func __indexOfThing(thing: AnyObject) -> UInt {
        return 0
    }
}

extension MyClass
{
    /// - 返回: 给定 `thing` 的下标, 如果没有就返回 `nil`。
    func indexOfThing(thing: AnyObject) -> Int?
    {
        let idx = Int(__indexOfThing(thing)) // call the original method
        if idx == NSNotFound { return nil }
        return idx
    }
}


