//
//  SignIn.swift
//  NeighborNinja
//
//  Created by Samast Varma on 6/27/16.
//  Copyright © 2016 Samast Varma. All rights reserved.
//

import UIKit

class SignIn: UIViewController {

    @IBOutlet weak var EmailSignIn: UITextField!
    @IBOutlet weak var PasswordSignIn: UITextField!
    @IBAction func SignInButton(sender: UIButton) {
        
        var email = self.EmailSignIn.text
        var password = self.PasswordSignIn.text
        
        let userEmail = EmailSignIn.text!
        let userPassword = PasswordSignIn.text!
        
        let userEmailStored = NSUserDefaults.standardUserDefaults().stringForKey("userEmail")
        let userPasswordStored = NSUserDefaults.standardUserDefaults().stringForKey("userPassword")
        
//        func get(){
//            let url = NSURL(string: "http://localhost:8888/loginAcc.php")
//            let data = NSData(contentsOfURL: url!)

        let request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:8888/loginAcc.php")!)
        request.HTTPMethod = "POST"
        let postString = "a=\(userEmail)&b=\(userPassword)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            
            print("response = \(response)")
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            print(responseString)
            if (responseString == "0"){
                print ("No account")
            }
            else {
                print ("Account found")
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isUserLoggedIn")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        task.resume()

        }
    
}