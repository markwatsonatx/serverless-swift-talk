import Foundation

public class CouchDBBulkDocsRequest {

    //    new_edits: false,
    //    docs: [{
    //      _id: XXX,
    //      _rev: 1-YYY,
    //      customProperty: 123,
    //      _revisions: {
    //        start: 1,
    //        ids: [YYY]
    //      }
    //    }]

    var docs: [CouchDBBulkDoc]
    
    public init(docs:[CouchDBBulkDoc]) {
        self.docs = docs
    }
    
    func toDictionary() -> [String:Any] {
        var docDicts: [[String:Any]] = []
        for doc in self.docs {
            docDicts.append(doc.toDictionary())
        }
        var dict:[String:Any] = [String:Any]();
        dict["new_edits"] = false
        dict["docs"] = docDicts
        return dict
    }

}