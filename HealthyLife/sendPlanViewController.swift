//
//  sendPlanViewController.swift
//  HealthyLife
//
//  Created by admin on 8/5/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Firebase

class sendPlanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var plan: NSDictionary!
    
    var followers = [Follower]()

    var sendToID = String()
    
    var nameOfPlan = String()
    
    var username = String()
    
    var selectedFollowerName = String()
    
  
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var noteTextField: UITextField!
    
    @IBAction func sendAction(sender: AnyObject) {
        
        let sendPlanRef =  DataService.dataService.baseRef.child("users").child(sendToID).child("activities_planned").child("sendedPlan").child(nameOfPlan)
        
        
        sendPlanRef.setValue(plan)
        sendPlanRef.child("note").setValue(noteTextField.text!)
        sendPlanRef.child("senderID").setValue((FIRAuth.auth()?.currentUser?.uid)!)
        
        
        DataService.dataService.userRef.child("tracking").child(sendToID).setValue(["name" : selectedFollowerName])
        
  
        dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        print(nameOfPlan)
        
        DataService.dataService.userRef.child("username").observeEventType(.Value, withBlock: { snapshot in
            self.username = snapshot.value as! String
            
            })
   
        
        
        DataService.dataService.userRef.child("activities_planned").child("yourPlan").child(nameOfPlan).observeEventType(.Value, withBlock: { snapshot in
            // viet lai model va set up lai doan nay
            self.plan = snapshot.value as! NSDictionary
       
        })
        
       
        
         DataService.dataService.userRef.child("trainee").observeEventType(.Value, withBlock: { snapshot in
            
            self.followers = []
           
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    
                    
                    // Make our jokes array for the tableView.
                    
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let follower = Follower(key: key, dictionary: postDictionary)
                        
                        // Items are returned chronologically, but it's more fun with the newest jokes first.
                        
                        self.followers.insert(follower, atIndex: 0)
                    }
                }
                
            }
            
            // Be sure that the tableView updates when there is new data.
            
            self.tableView.reloadData()
            
        })

        
        
        // Do any additional setup after loading the view.
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return followers.count
        
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("6666")
        cell?.textLabel?.text = followers[indexPath.row].Name as? String
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
        sendToID = followers[indexPath.row].Key as! String
        selectedFollowerName = followers[indexPath.row].Name as! String
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
