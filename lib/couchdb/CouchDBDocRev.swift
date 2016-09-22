import Foundation

public class CouchDBDocRev {
    
    var docId: String
    var revision: String
    var deleted: Bool
    
    init(docId: String, revision: String, deleted: Bool) {
        self.docId = docId;
        self.revision = revision
        self.deleted = deleted
    }
}