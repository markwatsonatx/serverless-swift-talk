func main(args: [String:Any]) -> [String:Any] {
    if let user = args["user"] as? String {
        return [ "message" : "Hello \(user)!" ]
    }
    else {
        return [ "message" : "Not authenticated." ]
    }
}