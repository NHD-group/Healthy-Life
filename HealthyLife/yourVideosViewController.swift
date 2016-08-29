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

    var videos = [Video]()
    var videoRef = FIRDatabaseReference()
    let storage = FIRStorage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        videoRef =  DataService.dataService.userRef.child("yourVideo")
        
        videoRef.observeEventType(.Value, withBlock: { snapshot in
            
            self.videos = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    // Make our jokes array for the tableView.
                    
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let video = Video(key: key, dictionary: postDictionary)
                        
                        // Items are returned chronologically, but it's more fun with the newest jokes first.
                        
                        self.videos.insert(video, atIndex: 0)
                    }
                }
                
            }
            
            // Be sure that the tableView updates when there is new data.
            
            self.dataArray = self.videos
            
        })
        
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.row)
        
        
        videoRef.child(videos[indexPath.row].key as String).removeValue()
        
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        let video = videos[indexPath.row] as Video
        let playerVC = NHDVideoPlayerViewController(nibName: String(NHDVideoPlayerViewController), bundle: nil)
        playerVC.playVideo(video.videoUrl, title: video.name)
        presentViewController(playerVC, animated: true, completion: nil)
    }
    
    @IBAction func backAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("videos") as! vidCellTableViewCell
        cell.video = videos[indexPath.row]
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "createPlan" {
            let controller = segue.destinationViewController as! addPlanVidViewController
            if let button = sender as? UIButton {
                let cell = button.superview?.superview as! vidCellTableViewCell
                controller.video = cell.video
            }
            
        }
        
    }
    
    @IBAction func onAddVideo(sender: AnyObject) {
        
        let vc = uploadVideoViewController(nibName: String(uploadVideoViewController), bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
}
