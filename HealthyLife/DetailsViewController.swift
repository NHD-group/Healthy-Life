//
//  DetailsViewController.swift
//  HealthyLife
//
//  Created by admin on 7/31/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Firebase

class DetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    
    var oldPlan = Bool()
  
    
    var selectedDemo: Demo!
    
    var ref =  FIRDatabase.database().reference()
    
    let defaults = NSUserDefaults.standardUserDefaults()

   
    
    @IBOutlet weak var newPlanView: UIView!
    
    @IBOutlet weak var videoview: UIWebView!
    
    @IBOutlet weak var repTextField: UITextField!
    
    @IBOutlet weak var setTextField: UITextField!
    
    @IBOutlet weak var addNewPlanButton: UIButton!
    
    @IBOutlet weak var addOldPlanButton: UIButton!
    
    @IBOutlet weak var planTextField: UITextField!
    
       @IBAction func tapAction(sender: AnyObject) {
        view.endEditing(true)
        
    }
    
   
    var nameOfPlan = [String]()
    
    @IBOutlet weak var tableView: UITableView!

    
    @IBAction func saveAction(sender: AnyObject) {
        
        
        let activity: Dictionary<String, AnyObject> = [
            "videoId": selectedDemo.idDemo,
            "name": selectedDemo.nameDemo,
            "rep" : repTextField.text!,
            "set" : setTextField.text!
            ]

        let planRef = DataService.dataService.activitiesPlannedRef.child("yourPlan").child(planTextField.text!)
        
        planRef.child("note").setValue("")
        planRef.child("plan_creatorID").setValue(DataService.currentUserID)
        planRef.child("plan_creatorName").setValue(DataService.currentUserName)
        planRef.child("activities").childByAutoId().setValue(activity)
        
        
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func oldPlanAction(sender: AnyObject) {
        tableView.hidden = false
        addOldPlanButton.hidden = true
        addNewPlanButton.hidden = true
     
    }
    
    
    @IBAction func newPlanAction(sender: AnyObject) {
        newPlanView.hidden = false
        
    }
    
    
    @IBAction func addToOldPlanAction(sender: AnyObject) {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.hidden = true
        newPlanView.hidden = true
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.dataService.userRef.child("activities_planned").child("yourPlan").observeEventType(.Value, withBlock: { snapshot in
            
            print(snapshot)
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
         
                for snap in snapshots {
                    
                    let key = snap.key
                    self.nameOfPlan.insert(key, atIndex: 0)
                    

                }
                
            }
        
            
            self.tableView.reloadData()
            //            MBProgressHUD.hideHUDForView(self.view, animated: true)
        
            
        })
        
        let id = selectedDemo.idDemo
        print(id)
        
        videoview.loadHTMLString("<iframe width=\"\(videoview.frame.width - 20 )\" height=\"\(videoview.frame.height)\" src=\"https://www.youtube.com/embed/\(id)\" frameborder=\"0\" allowfullscreen></iframe>", baseURL: nil)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return nameOfPlan.count
        
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("plan")
        cell?.textLabel?.text = nameOfPlan[indexPath.row]
        
        return cell!
    }
    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print(nameOfPlan[indexPath.row])
        newPlanView.hidden = false
        tableView.hidden = true
        planTextField.text = nameOfPlan[indexPath.row]
     
        
    }

    


       override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func cancelAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        
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