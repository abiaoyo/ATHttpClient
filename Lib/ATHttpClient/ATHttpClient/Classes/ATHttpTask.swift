import Foundation
import Alamofire

@objcMembers
public class ATHttpTask: NSObject{
    
    private var dataRequest:DataRequest?
    private var downloadRequest:DownloadRequest?
    
    init(_ dataReqeust:DataRequest?) {
        self.dataRequest = dataReqeust
    }
    init(downloadRequest:DownloadRequest?) {
        self.downloadRequest = downloadRequest
    }
    
    public func cancel() {
        dataRequest?.cancel()
        downloadRequest?.cancel()
    }
}

extension ATHttpTask {
    
    public func addToTaskBox(_ taskBox:ATHttpTaskBox) {
        taskBox.addTask(self)
    }
}

@objcMembers
public class ATHttpTaskBox : NSObject{
    
    var tasks = NSHashTable<ATHttpTask>.weakObjects()
    
    deinit {
        removeAll()
    }
    
    public func addTask(_ task: ATHttpTask) {
        tasks.add(task)
    }
    
    public func removeTask(_ task: ATHttpTask) {
        tasks.remove(task)
    }
    
    public func removeAll() {
        tasks.allObjects.forEach { task in
            task.cancel()
        }
    }
    
}
