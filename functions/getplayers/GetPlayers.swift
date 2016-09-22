import Dispatch
import Foundation
import KituraNet
import SwiftyJSON

func main(args: [String:Any]) -> [String:Any] {
    let couch = CouchDBClient(host: "db", scheme: "http", port: 5984, username: nil, password: nil)
    var response : [String:Any]?
    dispatch_sync(dispatch_get_global_queue(0, 0)) {
        couch.createDb(db: "players") { (couchResponse, error) in
            if (couchResponse != nil) {
                response = [ "players": [["name" : "Player 1"],["name" : "Player 2"]] ]
            }
            else {
                response = [ "error": "Error creating database."]
            }
        }
    }
    return response!
}

// TODO: $lib couchdb/CouchDBCreateDbResponse.swift

public class CouchDBCreateDbResponse {
    var ok: Bool

    public init(dict:[String:Any]) {
        self.ok = dict["ok"] as! Bool
    }
}

public class CouchDBSaveDocResponse {
    var id: String
    var ok: Bool
    var rev: String
    
    public init(dict:[String:Any]) {
        self.id = dict["id"] as! String
        self.ok = dict["ok"] as! Bool
        self.rev = dict["rev"] as! String
    }  
}

public enum CouchDBError: Swift.ErrorType {
    case EmptyResponse
}

public class CouchDBClient {
    
    var scheme = "http"
    var port = 80
    var host: String
    var username: String?
    var password: String?
    
    init(host: String, scheme: String, port: Int, username: String?, password: String?) {
        self.host = host
        self.scheme = scheme
        self.port = port
        self.username = username
        self.password = password
    }

    func createDb(db: String, completionHandler: (CouchDBCreateDbResponse?, Swift.ErrorType?) -> Void) {
        let options = self.createPutRequest(db: db, path: "")
        print("PUT /.")
        let req = HTTP.request(options) { response in
            do {
                print("Received response for /.")
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

    public func createDoc(db: String, doc: [String: Any], completionHandler: (CouchDBSaveDocResponse?, Swift.ErrorType?) -> Void) {
        do {
            let body = try JSON(doc).rawData()
		    let options = self.createPostRequest(db: db, path: "")
            print("POST /.")
            let req = HTTP.request(options) { response in
                do {
                    print("Received response for /.")
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
    
    func getAllDocs(db: String, completionHandler: ([Any]?, Swift.ErrorType?) -> Void) {
        let options = self.createGetRequest(db: db, path: "_all_docs")
        print("GET _all_docs.")
        let req = HTTP.request(options) { response in
            do {
                print("Received response for _all_docs.")
                let dict: [String:Any]? = try self.parseResponse(response: response, error: nil)
                if (dict != nil) {
                    if let rows = dict!["rows"] as? [Any] {
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

    // MARK: Helper Functions
    
    func createGetRequest(db: String, path: String) -> [ClientRequestOptions] {
        var options: [ClientRequestOptions] = self.createRequest(db: db, path: path)
        options.append(.method("GET"))
        return options
    }

    func createPostRequest(db: String, path: String) -> [ClientRequestOptions] {
        var options: [ClientRequestOptions] = self.createRequest(db: db, path: path)
        options.append(.method("POST"))
        return options
    }

    func createPutRequest(db: String, path: String) -> [ClientRequestOptions] {
        var options: [ClientRequestOptions] = self.createRequest(db: db, path: path)
        options.append(.method("PUT"))
        return options
    }

    func createRequest(db: String, path: String) -> [ClientRequestOptions] {
        var headers = [String:String]()
        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        if (self.username != nil && self.password != nil) {
            let loginString = "\(self.username!):\(self.password!)"
            let loginData: NSData? = loginString.data(using:NSUTF8StringEncoding)
            let base64LoginString = loginData!.base64EncodedString([])
            headers["Authorization"] = "Basic \(base64LoginString)"
        }
        var options: [ClientRequestOptions] = []
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
            print("Empty response.")
            throw CouchDBError.EmptyResponse
        }
        else {
            let str = try response!.readString()!
            print("Response = \(str)")
            if (str.characters.count > 0) {
                return JSON.parse(string: str).dictionaryObject
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
            print("Empty response.")
            throw CouchDBError.EmptyResponse
        }
        else {
            let str = try response!.readString()!
            print("Response = \(str)")
            if (str.characters.count > 0) {
                return JSON.parse(string: str).arrayObject
            }
            else {
                return nil
            }
        }
    }
}