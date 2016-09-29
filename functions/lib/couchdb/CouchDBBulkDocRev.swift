import Foundation

public class CouchDBBulkDocRev {
    
    //  {
    //    start: 1,
    //    ids: [YYY]
    //  }
    
    var start: Int64
    var ids: [String]
    
    public init(start:Int64, ids: [String]) {
        self.start = start
        self.ids = ids
    }
    
    func toDictionary() -> [String:Any] {
        var dict:[String:Any] = [String:Any]();
        dict["start"] = NSNumber(value:self.start)
        dict["ids"] = self.ids
        return dict
    }
}
