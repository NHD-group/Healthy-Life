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
        searchBar.placeholder = "Search Users"
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem()
        addSearchBarItem()
        onSearch()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("222", forIndexPath:  indexPath) as! NewFeedtablviewCellTableViewCell
        
        let user = dataArray[indexPath.row] as! UserProfile
        cell.configureCell(user, setImage: user.key)
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
                vc.currentUserID = user.key
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
    
    override func onSearch() {
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
        
        let ref = FIRDatabase.database().reference().child("users")
        
        var query = ref.queryOrderedByChild("followerCount")
        if searchText.characters.count > 0 {
            query = ref.queryOrderedByChild("username").queryStartingAtValue(searchText.lowercaseString).queryEndingAtValue(searchText.lowercaseString + "\u{f8ff}")
        }
        
        query.queryLimitedToFirst(20).observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            let array = self.getDataWith(snapshot)

            if searchText.characters.count > 0 {
                ref.queryOrderedByChild("username").queryStartingAtValue(searchText.uppercaseString).queryEndingAtValue(searchText.uppercaseString + "\u{f8ff}").queryLimitedToFirst(20).observeSingleEventOfType(.Value, withBlock: { snap in
                    
                    let anotherArray = self.getDataWith(snap)
                    if searchText.characters.count > 0 {
                        ref.queryOrderedByChild("username").queryStartingAtValue(searchText).queryEndingAtValue(searchText + "\u{f8ff}").queryLimitedToFirst(20).observeSingleEventOfType(.Value, withBlock: { sna in
                            
                            let otherArray = self.getDataWith(sna)
                            self.dataArray = Helper.filterDuplicate(array + anotherArray + otherArray)
                        })
                    } else {
                        self.dataArray = Helper.filterDuplicate(array + anotherArray)
                    }
                })
            } else {
                self.dataArray = Helper.filterDuplicate(array)
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
                if key != FIRAuth.auth()?.currentUser?.uid {
                let user = UserProfile(key: key, dictionary: postDictionary)
                
                users.insert(user, atIndex: 0)
                }
            }
        }
        
        return users
    }

    override func dismissKeyboard() {
        
        searchBar.resignFirstResponder()
    }
}
