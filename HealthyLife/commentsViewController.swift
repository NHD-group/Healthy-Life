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

class commentsViewController: BaseTableViewController {
    
    var KeyUid = String()
    var comments = [Comment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            
            self.dataArray = self.comments

            
        })
        // Do any additional setup after loading the view.
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("comments") as! commentCellTableViewCell
        
        cell.comment = comments[indexPath.row]
        
        return cell
    }

}
