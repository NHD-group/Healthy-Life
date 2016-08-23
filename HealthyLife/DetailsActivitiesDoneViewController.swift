//
//  DetailsActivitiesDoneViewController.swift
//  HealthyLife
//
//  Created by admin on 8/17/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import Firebase

class ActivitiesDone: NSObject {
    var key: String?
    var activityName: String?
    var nameOfPlan: String?
    var time: NSDate?
    
    init(key: String, dictionary: Dictionary<String, AnyObject>) {
        self.key = key
        
        activityName = dictionary["activityName"] as? String
        nameOfPlan = dictionary["nameOfPlan"] as? String
        
        if let T = dictionary["time"] as? Double {
            time = NSDate(timeIntervalSince1970: T/1000)
        }
        
    }
    
    
}




class DetailsActivitiesDoneViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var uid = String()
    var titleName = String()
    var activitiesDone = [ActivitiesDone]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.title = titleName
       
        tableView.backgroundColor = Configuration.Colors.lightGray
        
        DataService.dataService.userRef.child("tracking").child(uid).child("activitiesDone").observeEventType(.Value, withBlock: { snapshot in
            self.activitiesDone = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    // Make our jokes array for the tableView.
                    
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let activity = ActivitiesDone(key: key, dictionary: postDictionary)
                        
                        
                        // Items are returned chronologically, but it's more fun with the newest jokes first.
                        
                        self.activitiesDone.insert(activity, atIndex: 0)
                    }
                }
                
            }
            
            // Be sure that the tableView updates when there is new data.
            
            self.tableView.reloadData()
            

        })
        // Do any additional setup after loading the view.
    }
    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // 1. set the initial state of the cell
        cell.alpha = 0
        let transform = CATransform3DTranslate(CATransform3DIdentity, -250, 20, 0)
        cell.layer.transform = transform
        // 2. UIView Animation method to the final state of the cell
        UIView.animateWithDuration(0.3) {
            cell.alpha = 1.0
            cell.layer.transform = CATransform3DIdentity
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activitiesDone.count
        
    }
    
    
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ActivitiesDone") as! ActivitiesDoneCellTableViewCell
        
        cell.activity = activitiesDone[indexPath.row]
        
        return cell
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
