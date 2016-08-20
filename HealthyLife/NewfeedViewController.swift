//
//  NewfeedViewController.swift
//  HealthyLife
//
//  Created by admin on 8/1/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Firebase

class NewfeedViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    
    var users = [UserProfile]()
    var keys =  [String]()
    var chatKey = String()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.estimatedRowHeight = 130
//        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        let ref = FIRDatabase.database().reference()

        showLoading()
        
        

        ref.child("users").queryOrderedByChild("followerCount").queryLimitedToFirst(20).observeEventType(.Value, withBlock: { snapshot in
            
            self.users = []
            
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    
                    
                    // Make our jokes array for the tableView.
                    
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        self.keys.insert(key, atIndex: 0)
                        
                        let user = UserProfile(key: key, dictionary: postDictionary)
                        
                        
                        self.users.insert(user, atIndex: 0)
                        
                        
                    }
                }
                
            }
            
            // Be sure that the tableView updates when there is new data.
            
            self.tableView.reloadData()
            self.hideLoading()
            
            
            
            
        })
        
        


        // Do any additional setup after loading the view.
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("222", forIndexPath:  indexPath) as! NewFeedtablviewCellTableViewCell
        
        cell.configureCell(users[indexPath.row], setImage: keys[indexPath.row])
        
        
        return cell

    }
    
 
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "chat"
        {
            
           
            let DestViewController = segue.destinationViewController as! UINavigationController
            let controller = DestViewController.topViewController as! chatViewController


            if let button = sender as? UIButton {
                let cell = button.superview?.superview as! NewFeedtablviewCellTableViewCell
                controller.senderId = cell.currentUID
                controller.senderDisplayName = cell.currentUserName
                controller.chatKey = cell.chatKey
                controller.chatRoomTittle = cell.sellectedUsername
            }
        } else if let vc = segue.destinationViewController as? journalViewController {
            
            if let indexPath = tableView.indexPathForSelectedRow {
                vc.currentUserID = keys[indexPath.row]
                let user = users[indexPath.row]
                vc.currentUserName = user.username
            }
        } else if segue.identifier == "details" {
            let controller = segue.destinationViewController as! TrainerDetailViewController
            if let button = sender as? UIButton {
                let cell = button.superview?.superview as! NewFeedtablviewCellTableViewCell
                controller.trainerUid = cell.trainerUid
            }
        }
        
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    

}
