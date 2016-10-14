import Dispatch
import Foundation
import KituraNet
import SwiftyJSON

// $DefaultParam:jwt_secret

func main(args: [String:Any]) -> [String:Any] {
    let jwt = args["jwt"] as? String
    if (jwt != nil) {
        let jwtSecret = args["jwt_secret"] as! String
        var response : [String:Any]?
        do {
            let payload = try Decode().decode(jwt!, algorithm: .hs256(jwtSecret.data(using: .utf8)!))
            let accessToken = payload["access_token"]
            DispatchQueue.global().sync {
                var headers = ["User-Agent": "serverless-swift-talk",
                               "Content-Type": "application/json",
                               "Accepts": "application/json"]
                var options: [ClientRequest.Options] = []
                options.append(.headers(headers)) // User-Agent required by GitHub
                options.append(.schema("https://"))
                options.append(.hostname("api.github.com"))
                options.append(.path("/user?access_token=\(accessToken!)"))
                options.append(.method("GET"))
                let req = HTTP.request(options) { res in
                    if (res != nil) {
                        do {
                            let str = try res!.readString()!
                            if (str.characters.count > 0) {
                                response = try JSONSerialization.jsonObject(with:str.data(using:.utf8)!, options:[]) as? [String:Any]
                                if (response == nil) {
                                    response = ["str": str]
                                }
                            }
                            else {
                                response = ["error": "Invalid response"]
                            }
                        }
                        catch {
                            response = ["error": "\(error)"]
                        }
                    }
                    else {
                        response = ["error": "Error connecting to GitHub"]
                    }
                }
                req.end()
            }
        }
        catch {
            response = ["error" : "Invalid token."]
        }
        return response!
    }
    else {
        return ["error" : "Invalid token."]
    }
}

{% include "./lib/crypto/CollectionExtensions.swift" %}
{% include "./lib/crypto/Digest.swift" %}
{% include "./lib/crypto/HMAC.swift" %}
{% include "./lib/crypto/NumberExtensions.swift" %}
{% include "./lib/crypto/SHA2.swift" %}
{% include "./lib/crypto/Utils.swift" %}
{% include "./lib/crypto/ZeroPadding.swift" %}
{% include "./lib/jwt/Base64.swift" %}
{% include "./lib/jwt/Claims.swift" %}
{% include "./lib/jwt/Decode.swift" %}
{% include "./lib/jwt/JWT.swift" %}
