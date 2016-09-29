//
//  ViewController.swift
//  ServerlessSwiftTalkClient
//
//  Created by Mark Watson on 9/29/16.
//  Copyright © 2016 IBM CDS Labs. All rights reserved.
//

import SwiftyJSON
import UIKit

class ViewController: UIViewController {
    
    let HELLO_WORLD_URL = "https://openwhisk.ng.bluemix.net/api/v1/namespaces/markwats%40us.ibm.com_serverless-swift-talk/actions/HelloWorld?blocking=true"
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var helloWorldButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let username = AppState.loadUsername()
        if (username != nil) {
            self.usernameTextField.text = username
            let password = AppState.loadPassword(username!)
            if (password != nil) {
                self.passwordTextField.text = password
            }
        }
    }
    
    @IBAction func helloWorldButtonPressed(sender: UIButton) {
        let username = self.usernameTextField.text
        let password = self.passwordTextField.text
        if (username == nil || password == nil) {
            return
        }
        // save credentials
        AppState.saveUsernamePassword(username!, password: password!)
        // call OpenWhisk
        let url = URL(string: HELLO_WORLD_URL)
        let session = URLSession.shared
        let userPasswordString = "\(username!):\(password!)"
        let userPasswordData = userPasswordString.data(using: .utf8)
        let userPasswordBase64 = userPasswordData?.base64EncodedString()
        var request = URLRequest(url: url!)
        request.addValue("Basic \(userPasswordBase64!)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField:"Content-Type")
        request.addValue("application/json", forHTTPHeaderField:"Accepts")
        request.httpMethod = "POST"
        //
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            DispatchQueue.global().async {
                guard let _:Data = data, let _:URLResponse = response, error == nil else {
                    // fail silently
                    return
                }
                let json = JSON(data: data!)
                if let reply = json["response"]["result"]["reply"].string {
                    print("REPLY=\(reply)")
                }
            }
        });
        task.resume()
    }

}

