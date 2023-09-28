//
//  ViewController.swift
//  HelloworldSwift
//
//  Created by Rahul Mahore on 09/08/23.
//

import UIKit
import Bayun


class ViewController: UIViewController {
    var url = "https://www.digilockbox.com/"
    // For a consumer type use-case you can use app name as companyName. 
    var companyName = "company4App.<appName>"; // Please edit this field and provide a unique application name.
    var appId = "enter_bayun_application_id"
    var appSalt = "enter_bayun_application_salt"
    var appSecret = "enter_bayun_application_secret"

    @IBOutlet weak var companyEmployeeId: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBAction func btnLogin(_ sender: Any) {
        
        var strComEmpId = companyEmployeeId.text
        var strpassword = password.text
        
        if(strComEmpId == nil){
            strComEmpId=""
        }
        
        if(strpassword == nil){
            strpassword=""
        }
        
        
        loginWithPassword(compEmpId: strComEmpId ?? "", password: strpassword ?? "")
    }
    
    func loginWithPassword(compEmpId: String, password: String) {
        self.indicatorView.startAnimating()

        let appCredentials : BayunAppCredentials = BayunAppCredentials(appId: appId, appSecret: appSecret, appSalt: appSalt, baseURL:url)
        

        BayunCore.sharedInstance().login(withCompanyName: companyName,
                                         uiViewController: self,
                                               companyEmployeeId: compEmpId,
                                                        password: password,
                                              autoCreateEmployee: true,
                                       securityQuestionsCallback: nil,
                                                 passphraseCallback: nil, bayunAppCredentials: appCredentials, success: {
                       NSLog("Logged in with Bayun successfully.")

            DispatchQueue.main.async {
                self.indicatorView.stopAnimating()
                // Access UI stuff here
                let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "secondViewController") as! SecondViewController
                self.navigationController?.pushViewController(loginVC, animated: true)

            }


                     }, failure: {(error) in
                         self.indicatorView.stopAnimating()
                       NSLog("Login failed with error")
                })

       
        
 
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
      
        indicatorView.stopAnimating()
        
//        let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String
//        companyName =  "company4App."+(appName ?? "")
    }


}

