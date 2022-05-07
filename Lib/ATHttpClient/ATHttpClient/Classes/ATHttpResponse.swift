import Foundation
import HandyJSON
import JSONModel

open class ATHttpHandyJsonResponse<T>: HandyJSON{
    
    public var status:Int?
    
    public var message:String?
    
    public var data:T?
    
    required public init() {}
    
    open func mapping(mapper: HelpingMapper) {
        mapper <<< self.data <-- ["data", "client", "devices"]
    }
}

@objcMembers
open class ATHttpJsonModel: JSONModel {
    
    public var status:Int = 200
    
    public var message:String?
    
    public var data:Dictionary<String,Any>?
    
    open override class func propertyIsOptional(_ propertyName: String!) -> Bool {
        return true
    }
}
