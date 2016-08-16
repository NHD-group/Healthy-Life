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
    
    var key: NSString?
    var name: NSString?
    var des: NSString?
    var videoUrl: NSString?
    var vidDict: NSDictionary?
    
    
    
    init(key: String, dictionary: NSDictionary) {
        self.key = key
        
        name = dictionary["name"] as? String
        
        des = dictionary["description"] as? String
        
        videoUrl = dictionary["videoUrl"] as? String
        
        vidDict = dictionary
        
    }
    
}


class yourVideosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var videos = [Video]()
    var videoRef = FIRDatabaseReference()
    let storage = FIRStorage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
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
            
            self.tableView.reloadData()
            
        })
        
        tableView.allowsMultipleSelectionDuringEditing = true
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.row)
        
        
        
        let desertRef = storage.child("videos/\(videos[indexPath.row].key as! String)")
        // Delete the file
        desertRef.deleteWithCompletion { (error) -> Void in
            if (error != nil) {
                
                //                let alert = UIAlertController(title: "error", message: "\(error?.localizedDescription)", preferredStyle: .Alert )
                //                let okAction = UIAlertAction(title: "ok", style: .Default, handler: nil)
                //                alert.addAction(okAction)
                //
                //                self.presentViewController(alert, animated: true, completion: nil)
                //                 Uh-oh, an error occurred!
            } else {
                
                
                // File deleted successfully
            }
        }
        videoRef.child(videos[indexPath.row].key as! String).removeValue()
        
        
    }
    
    @IBAction func backAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("videos") as! vidCellTableViewCell
        cell.video = videos[indexPath.row]
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "videoSegue"
        {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let videoUrl = videos[indexPath!.row].videoUrl as! String
            let destination = segue.destinationViewController as! AVPlayerViewController
            
            let url = NSURL(string: videoUrl )
            destination.player = AVPlayer(URL: url!)
            
        } else if segue.identifier == "sendPlan" {
            let controller = segue.destinationViewController as! addPlanVidViewController
            if let button = sender as? UIButton {
                let cell = button.superview?.superview as! vidCellTableViewCell
                controller.video = cell.video
            }
            
        }
        
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
