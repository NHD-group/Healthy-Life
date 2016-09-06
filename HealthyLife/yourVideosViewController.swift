//
//  yourVideosViewController.swift
//  HealthyLife
//
//  Created by admin on 8/16/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import AVKit

class Video: NSObject {
    
    var key: String!
    var name: String?
    var des: String?
    var videoUrl: String?
    var vidDict: NSDictionary?
    
    
    
    init(key: String, dictionary: NSDictionary) {
        self.key = key
        
        name = dictionary["name"] as? String
        
        des = dictionary["description"] as? String
        
        videoUrl = dictionary["videoUrl"] as? String
        
        vidDict = dictionary
        
    }
    
}


class yourVideosViewController: BaseTableViewController {

    var videoRef = FIRDatabaseReference()
    let searchBar = UISearchBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    func setupSearchBar() {
        
        searchBar.sizeToFit()
        searchBar.placeholder = "Search Videos"
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        
        addSearchBarItem()
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.setBackgroundImage(UIImage(named: "icn-upload"), forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(self.onAddVideo(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        navigationItem.rightBarButtonItems?.insert(UIBarButtonItem(customView: button), atIndex: 0)
        
        onSearch()
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.row)
        
        
        videoRef.child(dataArray[indexPath.row].key as String).removeValue()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        let video = dataArray[indexPath.row] as! Video

        NHDVideoPlayerViewController.showPlayer(nil, orLink: video.videoUrl, title: video.name, inViewController: self)

    }
    
    @IBAction func backAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("videos") as! vidCellTableViewCell
        cell.video = dataArray[indexPath.row] as! Video
        cell.createPlanButton.tag = indexPath.row
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "createPlan" {
            let controller = segue.destinationViewController as! addPlanVidViewController
            if let button = sender as? UIButton {
                let video = dataArray[button.tag]
                controller.video = video as! Video
            }
            
        }
        
    }
    
    @IBAction func onAddVideo(sender: AnyObject) {
        
        let vc = uploadVideoViewController(nibName: String(uploadVideoViewController), bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension yourVideosViewController: UISearchBarDelegate {
    
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
        
        videoRef = DataService.dataService.userRef.child("yourVideo")
        
        var query = videoRef.queryOrderedByKey()
        if searchText.characters.count > 0 {
            query = videoRef.queryOrderedByChild("name").queryStartingAtValue(searchText.lowercaseString).queryEndingAtValue(searchText.lowercaseString + "\u{f8ff}")
        }
        
        query.queryLimitedToFirst(20).observeEventType(.Value, withBlock: { snapshot in
            
            let array = self.getDataWith(snapshot)
            
            if searchText.characters.count > 0 {
                self.videoRef.queryOrderedByChild("name").queryStartingAtValue(searchText.uppercaseString).queryEndingAtValue(searchText.uppercaseString + "\u{f8ff}").queryLimitedToFirst(20).observeSingleEventOfType(.Value, withBlock: { snap in
                    
                    let anotherArray = self.getDataWith(snap)
                    if searchText.characters.count > 0 {
                        self.videoRef.queryOrderedByChild("name").queryStartingAtValue(searchText).queryEndingAtValue(searchText + "\u{f8ff}").queryLimitedToFirst(20).observeSingleEventOfType(.Value, withBlock: { sna in
                            
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
    
    func getDataWith(snapshot: FIRDataSnapshot) -> [Video] {
        
        var videos = [Video]()
        guard let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] else {
            return videos
        }
        
        for snap in snapshots {
            // Make our jokes array for the tableView.
            
            if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                let key = snap.key
                let video = Video(key: key, dictionary: postDictionary)
                
                videos.insert(video, atIndex: 0)
            }
        }
        
        return videos
    }
    
    override func dismissKeyboard() {
        
        searchBar.resignFirstResponder()
    }
}
