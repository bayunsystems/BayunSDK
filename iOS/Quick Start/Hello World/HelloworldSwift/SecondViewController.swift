//
//  SecondViewController.swift
//  HelloworldSwift
//
//  Created by Rahul Mahore on 09/08/23.
//

import UIKit
import Bayun

class SecondViewController: UIViewController {
    @IBAction func btnLock(_ sender: Any) {
        var enterText = editText.text
        
        lockData(lockedText: enterText ?? "")
    }
    
    @IBAction func btnUnlock(_ sender: Any) {
        var lockText = loctText.text
        unLockData(lockedText: lockText ?? "")
    }
    @IBOutlet weak var editText: UITextField!
    
    
    @IBOutlet weak var unlockText: UITextField!
    
    
    @IBOutlet weak var loctText: UITextView!
    
    
    
    func lockData(lockedText: String){
        BayunCore .sharedInstance().lockText(lockedText, success: { (lockedText) in
            NSLog("Text locked successfully.")
            self.loctText.text = lockedText
         }, failure:  { (bayunErrorCode) in
            NSLog("Error locking text.");
         })
    }
    
    
    
    func unLockData(lockedText: String){
        BayunCore.sharedInstance().unlockText(lockedText, success: { (unlockedText) in
            
            NSLog("Text unlocked successfully.")
            self.unlockText.text = unlockedText
        }, failure: { (bayunErrorCode) in
            NSLog("Error unlocking text.")
        })
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
