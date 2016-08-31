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
    var pricePerWeek: String?
    var des: String?
    init(key: String, dictionary: NSDictionary ) {
        uid = key
        videoUrl = dictionary["videoUrl"] as? String
        des = dictionary["description"] as? String
        pricePerWeek = dictionary["pricePerWeek"] as? String
        
    }
}

class demoLibViewController: BaseTableViewController {
    
    var trailers = [Trailer]()
    
    @IBOutlet weak var addEditButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            
            self.dataArray = self.trailers
            
        })
        
        ref.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("demo").observeEventType(.Value, withBlock: { snapshot in
            
            if let check = snapshot.value as? NSNull {
                self.addEditButton.title = "Add"
            } else {
                self.addEditButton.title = "Edit"
            }
            
        })

        
    }
    
    @IBAction func addEditAction(sender: AnyObject) {
        if self.addEditButton.title == "Add" {
            performSegueWithIdentifier("add", sender: self)
        } else if self.addEditButton.title == "Edit" {
            performSegueWithIdentifier("edit", sender: self)
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "check")
            
        }

    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("demoCell") as? demoTableViewCell {
            
            cell.configureCell(trailers[indexPath.row])
            cell.priceButton.tag = indexPath.row
            cell.delegate = self

            return cell
            
        } else {
            
            return demoTableViewCell()
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "commentFromLib" {
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
        } else if segue.identifier == "fromDemos" {
            let controller = segue.destinationViewController as! PrictListViewController
            if let button = sender as? UIButton {
                let trailer = trailers[button.tag]
                controller.uid = trailer.uid!
                controller.pricePerWeek = trailer.pricePerWeek
            }
        }
        
    }
}

extension demoLibViewController: demoTableViewCellDelegate {
    
    func getHealthyAction(trailer: Trailer) {
        
        Helper.showAlert("Sign Up To This Trainer", message: "Please ask your trainers for new workoutplan", okActionBlock: {
            
            DataService.dataService.baseRef.child("users").child(trailer.uid!).child("trainee").child(DataService.currentUserID).child("name").setValue(DataService.currentUserName)
            }, cancelActionBlock: { 
                
            }, inViewController: self)
    }
    
    func onVideoTrainerTapped(videoUrl: NSURL) {
        
        let playerVC = NHDVideoPlayerViewController(nibName: String(NHDVideoPlayerViewController), bundle: nil)
        playerVC.playVideoWithURL(videoUrl, title: "Demo Lib")
        presentViewController(playerVC, animated: true, completion: nil)
    }
}
