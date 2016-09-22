import Foundation
import KituraNet
import LoggerAPI

public enum CouchDBError: Swift.Error {
    case EmptyResponse
}

public class CouchDBClient {
    
    var scheme = "http"
    var port = 80
    var host: String
    var username: String?
    var password: String?
    
    public init(host: String) {
        self.host = host
    }
    
    public init(host: String, username: String?, password: String?) {
        self.host = host
        self.username = username
        self.password = password
    }

    public init(host: String, scheme: String, port: Int) {
        self.host = host
        self.scheme = scheme
        self.port = port
    }
    
    public init(host: String, scheme: String, port: Int, username: String?, password: String?) {
        self.host = host
        self.scheme = scheme
        self.port = port
        self.username = username
        self.password = password
    }

    // MARK: db
    
    public func createDb(db: String, completionHandler: @escaping (CouchDBCreateDbResponse?, Swift.Error?) -> Void) {
        let options = self.createPutRequest(db: db, path: "")
        Log.info("PUT /.")
        let req = HTTP.request(options) { response in
            do {
                Log.info("Received response for /.")
                let dict: [String:Any]? = try self.parseResponse(response: response, error: nil)
                if (dict != nil) {
                    completionHandler(CouchDBCreateDbResponse(dict:dict!), nil)
                }
                else {
                    completionHandler(nil, nil)
                }
            }
            catch {
                completionHandler(nil, error)
            }
        }
        req.end()
    }

    public func createDoc(db: String, doc: [String: Any], completionHandler: @escaping (CouchDBSaveDocResponse?, Swift.Error?) -> Void) {
        do {
            let body = try JSONSerialization.data(withJSONObject:doc, options: [])
            let options = self.createPostRequest(db: db, path: "")
            Log.info("POST /.")
            let req = HTTP.request(options) { response in
                do {
                    Log.info("Received response for /.")
                    let dict: [String:Any]? = try self.parseResponse(response: response, error: nil)
                    if (dict != nil) {
                        completionHandler(CouchDBSaveDocResponse(dict:dict!), nil)
                    }
                    else {
                        completionHandler(nil, nil)
                    }
                }
                catch {
                    completionHandler(nil, error)
                }
            }
            req.write(from: body)
            req.end()
         }
         catch {
            completionHandler(nil, error)
        }
    }
    
    // MARK: _all_docs
    
    public func getAllDocs(db: String, completionHandler: @escaping ([Any]?, Swift.Error?) -> Void) {
        let options = self.createGetRequest(db: db, path: "_all_docs")
        Log.info("GET _all_docs.")
        let req = HTTP.request(options) { response in
            do {
                Log.info("Received response for _all_docs.")
                let dict: [String:Any]? = try self.parseResponse(response: response, error: nil)
                if (dict != nil) {
                    if let rows = dict!["rows"] as? [[String:Any]] {
                        completionHandler(rows, nil)
                    }
                    else {
                        completionHandler(nil, nil)
                    }
                }
                else {
                    completionHandler(nil, nil)
                }
            }
            catch {
                completionHandler(nil, error)
            }
        }
        req.end()
    }
    
    // MARK: _bulk_docs
    
    public func bulkDocs(db: String, docs: [CouchDBBulkDoc], completionHandler:  @escaping ([Any]?, Swift.Error?) -> Void) {
         do {
            let bulkDocRequest = CouchDBBulkDocsRequest(docs: docs)
            let body = try JSONSerialization.data(withJSONObject:bulkDocRequest.toDictionary(), options: [])
            let options = self.createPostRequest(db: db, path: "_bulk_docs")
            Log.info("POST _bulk_docs.")
            let req = HTTP.request(options) { response in
                do {
                    Log.info("Received response for _bulk_docs.")
                    let array: [Any]? = try self.parseResponseAsArray(response: response, error: nil)
                    if (array != nil) {
                        completionHandler(array, nil)
                    }
                    else {
                        completionHandler(nil, nil)
                    }
                }
                catch {
                    completionHandler(nil, error)
                }
            }
            req.write(from: body)
            req.end()
         }
         catch {
            completionHandler(nil, error)
        }
    }
    
    // MARK: _changes
    
    public func getChanges(db: String, since: String?, includeDocs: Bool, completionHandler: @escaping (CouchDBChanges?, Swift.Error?) -> Void) {
        var path = "_changes?include_docs=\(includeDocs)"
        if (since != nil) {
            path = "\(path)&since=\(since!)"
        }
        let options = self.createGetRequest(db: db, path: path)
        Log.info("GET _changes.")
        let req = HTTP.request(options) { response in
            do {
                Log.info("Received response for _changes.")
                let dict: [String:Any]? = try self.parseResponse(response: response, error: nil)
                if (dict != nil) {
                    completionHandler(CouchDBChanges(dict: dict!), nil)
                }
                else {
                    completionHandler(nil, nil)
                }
            }
            catch {
                completionHandler(nil, error)
            }
        }
        req.end()
    }
    
    // MARK: _local
    
    public func saveCheckpoint(db: String, replicationId: String, lastSequence: Int64, completionHandler: @escaping (Swift.Error?) -> Void) {
        do {
            let body = try JSONSerialization.data(withJSONObject:["lastSequence":"\(lastSequence)"], options: [])
            let options = self.createPutRequest(db: db, path: "_local/\(replicationId)")
            Log.info("PUT _local.")
            let req = HTTP.request(options) { response in
                do {
                    Log.info("Received response for _local.")
                    let dict: [String:Any]? = try self.parseResponse(response: response, error: nil)
                    if (dict != nil) {
                        Log.info("Save Checkpoint Response = \(dict!)")
                        completionHandler(nil)
                    }
                    else {
                        completionHandler(nil)
                    }
                }
                catch {
                    completionHandler(error)
                }
            }
            req.write(from: body)
            req.end()
        }
        catch {
            completionHandler(error)
        }
    }
    
    public func getCheckpoint(db: String, replicationId: String, completionHandler: @escaping (Int64?, Swift.Error?) -> Void) {
        let options = self.createGetRequest(db: db, path: "_local/\(replicationId)")
        Log.info("GET _local.")
        let req = HTTP.request(options) { response in
            do {
                let dict: [String:Any]? = try self.parseResponse(response: response, error: nil)
                if (dict != nil) {
                    Log.info("Get Checkpoint Response = \(dict!)")
                    let lastSequence = dict!["lastSequence"] as? Int64
                    completionHandler(lastSequence, nil)
                }
                else {
                    completionHandler(nil, nil)
                }
            }
            catch {
                completionHandler(nil, error)
            }
        }
        req.end()
    }
    
    // MARK: _revs_diff
    
    public func revsDiff(db: String, docRevs: [CouchDBDocRev], completionHandler: @escaping ([CouchDBDocMissingRevs]?, Swift.Error?) -> Void) {
        do {
            var dict = [String:[String]]()
            for docRev in docRevs {
                dict[docRev.docId] = [docRev.revision]
            }
            let body = try JSONSerialization.data(withJSONObject: dict, options: [])
            let options = self.createPostRequest(db: db, path: "_revs_diff")
            Log.info("PUT _revs_diff.")
            let req = HTTP.request(options) { response in
                do {
                    Log.info("Received response for _local.")
                    let dict: [String:Any]? = try self.parseResponse(response: response, error: nil)
                    if (dict != nil) {
                        var docMissingRevs: [CouchDBDocMissingRevs] = []
                        for key in dict!.keys {
                            let missingRevs = (dict?[key] as! [String:Any])["missing"] as! [String]
                            docMissingRevs.append(CouchDBDocMissingRevs(docId: key, missingRevs: missingRevs))
                        }
                        completionHandler(docMissingRevs, nil)
                    }
                    else {
                        completionHandler([], nil)
                    }
                }
                catch {
                    completionHandler(nil, error)
                }
            }
            req.write(from: body)
            req.end()
        }
        catch {
            completionHandler(nil, error)
        }
    }
    
    // MARK: Helper Functions
    
    func createGetRequest(db: String, path: String) -> [ClientRequest.Options] {
        var options: [ClientRequest.Options] = self.createRequest(db: db, path: path)
        options.append(.method("GET"))
        return options
    }

    func createPostRequest(db: String, path: String) -> [ClientRequest.Options] {
        var options: [ClientRequest.Options] = self.createRequest(db: db, path: path)
        options.append(.method("POST"))
        return options
    }

    func createPutRequest(db: String, path: String) -> [ClientRequest.Options] {
        var options: [ClientRequest.Options] = self.createRequest(db: db, path: path)
        options.append(.method("PUT"))
        return options
    }

    func createRequest(db: String, path: String) -> [ClientRequest.Options] {
        var headers = [String:String]()
        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        if (self.username != nil && self.password != nil) {
            let loginString = "\(self.username!):\(self.password!)"
            let loginData: Data? = loginString.data(using:String.Encoding.utf8)
            let base64LoginString = loginData!.base64EncodedString(options:[])
            headers["Authorization"] = "Basic \(base64LoginString)"
        }
        var options: [ClientRequest.Options] = []
        options.append(.headers(headers))
        options.append(.schema("\(self.scheme)://"))
        options.append(.hostname(self.host))
        options.append(.port(Int16(port)))
        options.append(.path("/\(db)/\(path)"))
        return options
    }
    
    func parseResponse(response:ClientResponse?, error:NSError?) throws -> [String:Any]? {
        if (error != nil) {
            throw error!
        }
        else if (response == nil) {
            Log.info("Empty response.")
            throw CouchDBError.EmptyResponse
        }
        else {
            let str = try response!.readString()!
            Log.info("Response = \(str)")
            if (str.characters.count > 0) {
                return try JSONSerialization.jsonObject(with:str.data(using:String.Encoding.utf8)!, options:[]) as? [String:Any]
            }
            else {
                return nil
            }
        }
    }

    func parseResponseAsArray(response:ClientResponse?, error:NSError?) throws -> [Any]? {
        if (error != nil) {
            throw error!
        }
        else if (response == nil) {
            Log.info("Empty response.")
            throw CouchDBError.EmptyResponse
        }
        else {
            let str = try response!.readString()!
            Log.info("Response = \(str)")
            if (str.characters.count > 0) {
                return try JSONSerialization.jsonObject(with:str.data(using:String.Encoding.utf8)!, options:[]) as? [Any]
            }
            else {
                return nil
            }
        }
    }
    
}