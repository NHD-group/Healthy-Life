//
//  PrictListViewController.swift
//  HealthyLife
//
//  Created by admin on 8/29/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import Firebase

class PrictListViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var uid = String()
    
    let currentUid = (FIRAuth.auth()?.currentUser?.uid)!
    
    var check = Bool()
    
    
    @IBOutlet weak var addEditButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        
        if uid != currentUid {
            addEditButton.title = nil
            tableView.allowsMultipleSelectionDuringEditing = true
        } else {
            tableView.allowsMultipleSelectionDuringEditing = false
            
        }
        
        
        
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "check")
        
        
     
        // Do any additional setup after loading the view.
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.row)
        
        
//        videoRef.child(videos[indexPath.row].key as! String).removeValue()
        
        
    }

    

    @IBAction func addAction(sender: AnyObject) {
        onBack()
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
   
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("priceList")
       
        return cell!
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
