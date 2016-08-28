//
//  NewfeedViewController.swift
//  HealthyLife
//
//  Created by admin on 8/1/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Firebase

class NewfeedViewController: BaseTableViewController {
    
    var chatKey = String()
    let searchBar = UISearchBar()
    var isAlreadyLoaded = false
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if isAlreadyLoaded {
            return
        }
        isAlreadyLoaded = true
        
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", style: .Plain, target: self, action: #selector(self.onSearch))
        
        
        onSearch()
        // Do any additional setup after loading the view.
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("222", forIndexPath:  indexPath) as! NewFeedtablviewCellTableViewCell
        
        let user = dataArray[indexPath.row] as! UserProfile
        cell.configureCell(user, setImage: user.UserKey)
        cell.talkButton.tag = indexPath.row
        
        return cell

    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 170
    }
 
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "chat"
        {
            
           
            let DestViewController = segue.destinationViewController as! UINavigationController
            let controller = DestViewController.topViewController as! chatViewController


            if let button = sender as? UIButton {
                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: button.tag, inSection: 0)) as! NewFeedtablviewCellTableViewCell
                controller.senderId = cell.currentUID
                controller.senderDisplayName = cell.currentUserName
                controller.chatKey = cell.chatKey
                controller.chatRoomTittle = cell.sellectedUsername
            }
        } else if let vc = segue.destinationViewController as? journalViewController {
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let user = dataArray[indexPath.row] as! UserProfile
                vc.currentUserID = user.UserKey
                vc.currentUserName = user.username
            }
        } else if segue.identifier == "details" {
            let controller = segue.destinationViewController as! TrainerDetailViewController
            if let button = sender as? UIButton {
                let cell = button.superview?.superview?.superview as! NewFeedtablviewCellTableViewCell
                controller.trainerUid = cell.trainerUid
            }
        }
        
    }

}

extension NewfeedViewController: UISearchBarDelegate {
    
    func onSearch() {
        filterContentForSearchText(searchBar.text ?? "")
        dismissKeyboard()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        onSearch()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        onSearch()
    }
    
    func filterContentForSearchText(searchText: String) {
        
        let ref = FIRDatabase.database().reference()
        
        var query = ref.child("users").queryOrderedByChild("followerCount")
        if searchText.characters.count > 0 {
            query = ref.child("users").queryOrderedByChild("username").queryStartingAtValue(searchText.lowercaseString).queryEndingAtValue(searchText.lowercaseString + "\u{f8ff}")
        }
        
        query.queryLimitedToFirst(20).observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            let array = self.getDataWith(snapshot)

            if searchText.characters.count > 0 {
                ref.child("users").queryOrderedByChild("username").queryStartingAtValue(searchText.uppercaseString).queryEndingAtValue(searchText.uppercaseString + "\u{f8ff}").queryLimitedToFirst(20).observeSingleEventOfType(.Value, withBlock: { snap in
                    
                    let anotherArray = self.getDataWith(snap)
                    self.dataArray = array + anotherArray
                })
            } else {
                self.dataArray = array
            }
        })
        
     
    }
    
    func getDataWith(snapshot: FIRDataSnapshot) -> [UserProfile] {
        
        var users = [UserProfile]()
        guard let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] else {
            return users
        }
        
        for snap in snapshots {
            // Make our jokes array for the tableView.
            
            if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                let key = snap.key
                let user = UserProfile(key: key, dictionary: postDictionary)
                
                users.insert(user, atIndex: 0)
            }
        }
        
        return users
    }
    
    override func dismissKeyboard() {
        
        searchBar.resignFirstResponder()
    }
}
