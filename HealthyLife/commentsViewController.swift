//
//  commentsViewController.swift
//  HealthyLife
//
//  Created by admin on 8/17/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import NSDate_TimeAgo
import Firebase

class Comment: NSObject {
    var key: String?
    var text: String?
    var time: NSDate?
    
    init(key: String, dictionary: Dictionary<String, AnyObject>) {
        self.key = key
        
        text = dictionary["text"] as? String
        
        if let T = dictionary["time"] as? Double {
            time = NSDate(timeIntervalSince1970: T/1000)
        }
        
    }
    
   
}

class commentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var KeyUid = String()
    var comments = [Comment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        
        tableView.backgroundColor = Configuration.Colors.lightGray
        DataService.BaseRef.child("users").child(KeyUid).child("usersComment").observeEventType(.Value, withBlock: { snapshot in
            
            self.comments = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    // Make our jokes array for the tableView.
                    
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let comment = Comment(key: key, dictionary: postDictionary)
                       
                        
                        // Items are returned chronologically, but it's more fun with the newest jokes first.
                        
                        self.comments.insert(comment, atIndex: 0)
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
        UIView.animateWithDuration(0.5) {
            cell.alpha = 1.0
            cell.layer.transform = CATransform3DIdentity
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
        
    }
    
    
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("comments") as! commentCellTableViewCell
        
        cell.comment = comments[indexPath.row]
        
        return cell
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
