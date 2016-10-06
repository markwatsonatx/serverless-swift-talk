/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

// KituraSample shows examples for creating custom routes.

import Foundation

import Kitura
import SwiftyJSON

#if os(Linux)
    import Glibc
#endif

// All Web apps need a router to define routes
let router = Router()

/**
* RouterMiddleware can be used for intercepting requests and handling custom behavior
* such as authentication and other routing
*/
class BasicAuthMiddleware: RouterMiddleware {
    func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
        let authString = request.headers["Authorization"]
        print("Authorization: \(authString)")
        // Check authorization string in database to approve the request if fail
        // response.error = NSError(domain: "AuthFailure", code: 1, userInfo: [:])
        next()
    }
}

// This route executes the echo middleware
router.all(middleware: BasicAuthMiddleware())

router.all("/static", middleware: StaticFileServer())

router.post("/function/:function") { request, response, next in
    let f = request.parameters["function"]!
    do {
		let funcReqStr = try request.readString()
		let funcReqJsonObj = JSON.parse(string: funcReqStr!).dictionaryObject
		let funcResp = FunctionRunner.run(function: f, args:funcReqJsonObj!)
		let funcRespJsonObj = JSON(funcResp)
		response.headers["Content-Type"] = "application/json"
		try response.send(data: funcRespJsonObj.rawData()).end()
	}
	catch {
        print("Failed to send response \(error)")
    }
}

// Handles any errors that get set
router.error { request, response, next in
    response.headers["Content-Type"] = "text/plain; charset=utf-8"
    do {
        let errorDescription: String
        if let error = response.error {
            errorDescription = "\(error)"
        } else {
            errorDescription = "Unknown error"
        }
        try response.send("Caught the error: \(errorDescription)").end()
    }
    catch {
        print("Failed to send response \(error)")
    }
}

// A custom Not found handler
router.all { request, response, next in
    if  response.statusCode == .unknown  {
        // Remove this wrapping if statement, if you want to handle requests to / as well
        if  request.originalURL != "/"  &&  request.originalURL != ""  {
            try response.status(.notFound).send("Route not found in Sample application!").end()
        }
    }
    next()
}

// Add HTTP Server to listen on port 8090
Kitura.addHTTPServer(onPort: 8090, with: router)

// start the framework - the servers added until now will start listening
Kitura.run()
