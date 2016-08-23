//
//  demoLibViewController.swift
//  HealthyLife
//
//  Created by admin on 7/31/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import AVKit

class Trailer: NSObject {
    var uid: String?
    var videoUrl: String?
    var des: String?
    init(key: String, dictionary: NSDictionary ) {
        uid = key
        videoUrl = dictionary["videoUrl"] as? String
        des = dictionary["description"] as? String
        
    }
}

class demoLibViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var trailers = [Trailer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.backgroundColor = Configuration.Colors.lightGray
        tableView.separatorStyle = .None
        
        
//        FIRDatabase.database().reference().child("videosTrailer").child(currentUid)
//        ["videoUrl": videoUrl, "description": self.desTextView.text!]
       
        
        let ref = DataService.BaseRef

        showLoading()
        ref.child("videosTrailer").observeEventType(.Value, withBlock: { snapshot in
            
            self.trailers = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    
                    
                    // Make our jokes array for the tableView.
                    
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let demo = Trailer(key: key, dictionary: postDictionary)
                        
                        // Items are returned chronologically, but it's more fun with the newest jokes first.
                        
                        self.trailers.insert(demo, atIndex: 0)
                    }
                }
                
            }
            
            // Be sure that the tableView updates when there is new data.
            
            self.tableView.reloadData()
            self.hideLoading()
            
        })
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trailers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("demoCell") as? demoTableViewCell {
            
            cell.configureCell(trailers[indexPath.row])
            cell.navigationController = self.navigationController

            return cell
            
        } else {
            
            return demoTableViewCell()
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "playtrailer" {
            
            
            let controller = segue.destinationViewController as! AVPlayerViewController
            if let button = sender as? UIButton {
                let cell = button.superview?.superview?.superview as! demoTableViewCell
                let videoUrl = cell.videoUrl
                controller.player = AVPlayer(URL: videoUrl)
                controller.player?.play()

                
            }
            
        } else if segue.identifier == "commentFromLib" {
            let controller = segue.destinationViewController as! commentsViewController
            if let button = sender as? UIButton {
                let cell = button.superview?.superview?.superview as! demoTableViewCell
                controller.KeyUid = cell.uid
            }
        } else if segue.identifier == "chattrainer" {
            
            
            let DestViewController = segue.destinationViewController as! UINavigationController
            let controller = DestViewController.topViewController as! chatViewController
            
            
            if let button = sender as? UIButton {
                let cell = button.superview?.superview?.superview as! demoTableViewCell
                controller.senderId = cell.currentUid
                controller.senderDisplayName = cell.currentUserName
                controller.chatKey = cell.chatKey
                controller.chatRoomTittle = cell.selectedUsername
            }
        }
        
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    
    
       
    
}
