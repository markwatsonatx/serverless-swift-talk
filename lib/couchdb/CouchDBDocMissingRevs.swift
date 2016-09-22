import Foundation

public class CouchDBDocMissingRevs {
    
    var docId: String
    var missingRevs: [String]
    
    init(docId: String, missingRevs: [String]) {
        self.docId = docId
        self.missingRevs = missingRevs
    }

}