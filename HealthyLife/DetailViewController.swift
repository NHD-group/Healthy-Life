//
//  DetailViewController.swift
//  HealthyLife
//
//  Created by admin on 8/1/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Firebase

class DetailViewController: UIViewController {
    
    var activity: Activities!
  
    var creatorID = String()
    var nameOfPlan = String()
    var activityName = String()
    var trackingRef: FIRDatabaseReference!

    @IBOutlet weak var videoView: UIWebView!
    
    @IBOutlet weak var finishButtonLable: UIButton!
    
    @IBOutlet weak var repCountLabel: UILabel!
    
    @IBOutlet weak var setCountLabel: UILabel!
    
    @IBOutlet weak var startButtonLabel: UIButton!
    
    @IBOutlet weak var amountView: UIView!
    
    @IBAction func startButtonAction(sender: AnyObject) {
        finishButtonLable.hidden = false
        amountView.hidden = false
        
        videoView.hidden = true
        startButtonLabel.hidden = true
        
        trackingRef.setValue(["activityName": activity.name , "nameOfPlan": nameOfPlan])
        
        
    }
    
   
    
    @IBAction func cancelAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    @IBAction func finishAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        trackingRef.removeValue()
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trackingRef = DataService.dataService.baseRef.child("users").child(creatorID).child("tracking").child(DataService.currentUserID).child("workingOn")

        finishButtonLable.hidden = true
        amountView.hidden = true
        let id = activity.idVideo
        print(id)
        

        
        
        
        repCountLabel.text = activity.rep
        setCountLabel.text = activity.set
        
        
        videoView.loadHTMLString("<iframe width=\"\(videoView.frame.width - 20 )\" height=\"\(videoView.frame.height)\" src=\"https://www.youtube.com/embed/\(id)\" frameborder=\"0\" allowfullscreen></iframe>", baseURL: nil)
        

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
