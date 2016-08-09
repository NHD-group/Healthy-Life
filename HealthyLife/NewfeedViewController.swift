//
//  NewfeedViewController.swift
//  HealthyLife
//
//  Created by admin on 8/1/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Firebase

class NewfeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var users = [UserProfile]()
    var keys =  [String]()
    var chatKey = String()
    let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        DataService.dataService.baseRef.child("users").queryOrderedByChild("followerCount").observeEventType(.Value, withBlock: { snapshot in
            
            self.users = []
            self.keys = []
            
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
            //            MBProgressHUD.hideHUDForView(self.view, animated: true)
            

            
        })

        // Do any additional setup after loading the view.
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("user", forIndexPath:  indexPath) as! NewFeedtablviewCellTableViewCell
        
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
        }
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let defauls = NSUserDefaults.standardUserDefaults()
        defauls.setValue(keys[indexPath.row], forKey: "currentID")
        defauls.setBool(false, forKey: "checkID")
        
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
