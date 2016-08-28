//
//  talksViewController.swift
//  HealthyLife
//
//  Created by admin on 8/8/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Firebase

class talksViewController: BaseTableViewController {

    
    let currentUID = DataService.currentUserID
    var currentUserName = DataService.currentUserName
    let defaults = NSUserDefaults.standardUserDefaults()
    var isAlreadyLoaded = false
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if isAlreadyLoaded {
            return
        }
        isAlreadyLoaded = true
        
        showLoading()
        DataService.dataService.chatRoom.queryLimitedToLast(20).observeEventType(.Value, withBlock: { snapshot in
            
            
          var array = [NSObject]()
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    // Make our jokes array for the tableView.
                    
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let chatter = Chatter(key: key, dictionary: postDictionary)
                        
                        // Items are returned chronologically, but it's more fun with the newest jokes first.
                        
                        array.insert(chatter, atIndex: 0)
                    }
                }
                
            }
            
            self.dataArray = array
        })
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("talks") as! TalksCellTableViewCell
        cell.chatter = dataArray[indexPath.row] as? Chatter
        return cell
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "talksSegue"
        {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let chatter = dataArray[indexPath!.row] as! Chatter
            let chatKey = chatter.chatRoomKey
            let chatRoomName = chatter.chatterName
            let DestViewController = segue.destinationViewController as! UINavigationController
            let controller = DestViewController.topViewController as! chatViewController
            controller.chatKey = chatKey
            controller.senderId = currentUID
            controller.senderDisplayName = currentUserName
            controller.chatRoomTittle = chatRoomName
            
            
        }
    }
    

}
