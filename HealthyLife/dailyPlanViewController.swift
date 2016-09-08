//
//  dailyPlanViewController.swift
//  HealthyLife
//
//  Created by admin on 8/1/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Firebase

class dailyPlanViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    
    var activities = [Activities]()
    var plan: Plan!
    var key = String()
    var creatorID = String()
    var segue = String()
    var activityRef: FIRDatabaseReference!
    
    func alerMessage() {
        let alert = UIAlertController(title: "your workout plan is expired ", message: "Pleas ask your trainers for new workoutplan", preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "ok", style: .Default) { (UIAlertAction) in
            self.navigationController?.popViewControllerAnimated(true)

        }
        alert.addAction(alertAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        tableView.backgroundColor = Configuration.Colors.lightGray

        
        activityRef = DataService.dataService.activitiesPlannedRef.child(segue).child(key).child("activities")
        
        showLoading()
       activityRef.observeEventType(.Value, withBlock: { snapshot in
            self.activities = []
            if snapshot.value is NSNull  {
                
                self.alerMessage()
                DataService.dataService.activitiesPlannedRef.child(self.segue).child(self.key).removeValue()
             

            }
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    
                    
                    // Make our jokes array for the tableView.
                    
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let activity = Activities(key: key, dictionary: postDictionary)
                        
                        // Items are returned chronologically, but it's more fun with the newest jokes first.
                        
                        self.activities.insert(activity, atIndex: 0)
                        
                        
                    }
                }
                
            }
            
            // Be sure that the tableView updates when there is new data.
            
            self.tableView.reloadData()
            self.hideLoading()
        })
        
        
        tableView.allowsMultipleSelectionDuringEditing = true
        
        
        
    }
    
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        
        activityRef.child(activities[indexPath.row].keyDaily ).removeValue()
        
        
    }

    
    @IBAction func backAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("daily") as! cellDailyTableViewCell
        
        cell.activity = activities[indexPath.row]
        
        if activities[indexPath.row].finsihCount == 3 {
            DataService.dataService.activitiesPlannedRef.child(segue).child(key).child("activities").child(activities[indexPath.row].keyDaily).removeValue()
        }

        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let activity = activities[indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.activity = activity
        detailViewController.creatorID = activity.creatorID
        detailViewController.nameOfPlan = key
        detailViewController.segue = self.segue
        
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
