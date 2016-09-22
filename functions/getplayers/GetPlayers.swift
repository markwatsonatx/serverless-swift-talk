import Dispatch
import Foundation
import KituraNet
import SwiftyJSON

func main(args: [String:Any]) -> [String:Any] {
    let couchdbConfig = args["couchdb"] as! [String:Any]
    let couchdbClient = CouchDBClient(
        host: couchdbConfig["host"] as! String,
        scheme: couchdbConfig["scheme"] as! String,
        port: couchdbConfig["port"] as! Int,
        username: couchdbConfig["username"] as? String,
        password: couchdbConfig["password"] as? String
    )
    let db = couchdbConfig["db"] as! String
    var response : [String:Any]?
    dispatch_sync(dispatch_get_global_queue(0, 0)) {
        couchdbClient.createDb(db: db) { (couchResponse, error) in
            if (error != nil) {
                response = [ "error": "Error creating database."]
            }
            else {
                response = [ "players": [["name" : "Player 1"],["name" : "Player 2"]] ]
            }
        }
    }
    return response!
}

// $DefaultParam:couchdb
// $EmbedFile:couchdb/CouchDBCreateDbResponse.swift
// $EmbedFile:couchdb/CouchDBSaveDocResponse.swift
// $EmbedFile:couchdb/CouchDBClient.swift