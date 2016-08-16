//
//  talksViewController.swift
//  HealthyLife
//
//  Created by admin on 8/8/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Firebase

class talksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var chatters = [Chatter]()
    
    let currentUID = DataService.currentUserID
    var currentUserName = DataService.currentUserName
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
                
        DataService.dataService.chatRoom.queryLimitedToLast(20).observeEventType(.Value, withBlock: { snapshot in
            
            
            
            
            self.chatters = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    // Make our jokes array for the tableView.
                    
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let chatter = Chatter(key: key, dictionary: postDictionary)
                        
                        // Items are returned chronologically, but it's more fun with the newest jokes first.
                        
                        self.chatters.insert(chatter, atIndex: 0)
                    }
                }
                
            }
            
            // Be sure that the tableView updates when there is new data.
            
            self.tableView.reloadData()
            //            MBProgressHUD.hideHUDForView(self.view, animated: true)
        })
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatters.count
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("talks") as! TalksCellTableViewCell
        cell.chatter = chatters[indexPath.row]
        return cell
        
    }
    

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "talksSegue"
        {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let chatKey = chatters[indexPath!.row].chatRoomKey as! String
            let chatRoomName = chatters[indexPath!.row].chatterName as? String
            let DestViewController = segue.destinationViewController as! UINavigationController
            let controller = DestViewController.topViewController as! chatViewController
            controller.chatKey = chatKey
            controller.senderId = currentUID
            controller.senderDisplayName = currentUserName
            controller.chatRoomTittle = chatRoomName
            
            
        }
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
