//
//  addPlanVidViewController.swift
//  HealthyLife
//
//  Created by admin on 8/16/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import Firebase

class addPlanVidViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    var nameOfPlan = [String]()
    var video: Video!
    var planRef = DataService.dataService.userRef.child("activities_planned").child("yourPlan")
    

    @IBOutlet weak var actionView: UIView!
    
    @IBOutlet weak var addToNewPlanButton: UIButton!
    
    @IBOutlet weak var addToOldPlanButton: UIButton!
    
   
    
    
    @IBOutlet weak var repTextField: UITextField!
    
    @IBOutlet weak var setTextField: UITextField!

    @IBOutlet weak var nameOfPlanTextField: UITextField!
    
    @IBAction func addNewPlanAction(sender: AnyObject) {
        newplanView()
    }
    
    
    @IBAction func addOldPlanAction(sender: AnyObject) {
        oldOldPlanView()
    }
    
    
    @IBAction func cancelBackAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func addAction(sender: AnyObject) {
        let activity = ["name": video.name!, "videoUrl": video.videoUrl!, "description": video.des!, "rep": repTextField.text!, "set": setTextField.text!, "creatorID": (FIRAuth.auth()?.currentUser?.uid)!, "finishCount": 0 ]
        
        planRef.child(nameOfPlanTextField.text!).child("activities").childByAutoId().setValue(activity)
        
        dismissViewControllerAnimated(true, completion: nil)

        
    }
    
    
    @IBAction func cancelViewAction(sender: AnyObject) {
        startingView()
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    func startingView() {
        actionView.hidden = true
        tableView.hidden = true
        addToNewPlanButton.hidden = false
        addToOldPlanButton.hidden = false
       

        
    }
    
    func newplanView() {
        actionView.hidden = false
        addToNewPlanButton.hidden = true
        addToOldPlanButton.hidden = true
        
        tableView.hidden = true
    }
    
    func oldOldPlanView() {
        actionView.hidden = true
        addToNewPlanButton.hidden = true
        addToOldPlanButton.hidden = true
        
        tableView.hidden = false
        
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        startingView()
        
        showLoading()
        planRef.observeEventType(.Value, withBlock: { snapshot in
            
            print(snapshot)
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    let key = snap.key
                    self.nameOfPlan.insert(key, atIndex: 0)
                    
                    
                }
                
            }
            
            
            self.tableView.reloadData()
            self.hideLoading()
            
        })
        
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameOfPlan.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("planVid")
        
        cell?.textLabel?.text = nameOfPlan[indexPath.row]
        
        return cell!
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        nameOfPlanTextField.text = nameOfPlan[indexPath.row]
        newplanView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
