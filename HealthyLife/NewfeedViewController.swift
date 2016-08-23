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
   
   
    
    var users = [UserProfile]() {
        didSet {
            
            tableView.reloadData()
        }
    }
    
    var searchUser = [UserProfile]()
    var nonSearchUser = [UserProfile]()
    var keys =  [String]()
    var chatKey = String()
    let searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0)

//        tableView.estimatedRowHeight = 130
//        tableView.rowHeight = UITableViewAutomaticDimension
        
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", style: .Plain, target: self, action: #selector(self.onSearch))
        
        
        onSearch()
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
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("222", forIndexPath:  indexPath) as! NewFeedtablviewCellTableViewCell
        
        cell.configureCell(users[indexPath.row], setImage: keys[indexPath.row])
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
                vc.currentUserID = keys[indexPath.row]
                let user = users[indexPath.row]
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

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
                    self.users = array + anotherArray
                })
            } else {
                self.users = array
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
                self.keys.insert(key, atIndex: 0)
                
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
