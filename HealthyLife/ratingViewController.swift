//
//  ratingViewController.swift
//  HealthyLife
//
//  Created by admin on 8/17/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import Firebase

class ratingViewController: UIViewController {
    
    var KeyUID: String!

    @IBOutlet weak var starCountLabel: UILabel!
    
    @IBOutlet weak var commentTextField: UITextField!
    
    var trainerID: FIRDatabaseReference!
    var totalPeopleVoted = Int()
    var totalRate = Int()
    var userCommentCount = Int()
    var nameOfPlan = String()
    
    
    
    @IBOutlet weak var stepperValue: UIStepper!
    override func viewDidLoad() {
        super.viewDidLoad()

       trainerID = FIRDatabase.database().reference().child("users").child(KeyUID)
        // Do any additional setup after loading the view.
        
        trainerID.child("totalPeoleVoted").observeEventType(.Value, withBlock: { snapshot in
          print(snapshot.value)
            self.totalPeopleVoted = snapshot.value as! Int
        })
        
        
        trainerID.child("totalRate").observeEventType(.Value, withBlock: { snapshot in
            self.totalRate = snapshot.value as! Int
        })
        
        trainerID.child("userCommentsCount").observeEventType(.Value, withBlock: { snapshot in
            self.userCommentCount = snapshot.value as! Int
        })

       
        
        
//        "totalRate": 0, "totalPeoleVoted": 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func stepperStarCount(sender: AnyObject) {
        
            starCountLabel.text = "\(Int(stepperValue.value))"
            
    }

    @IBAction func submitAction(sender: AnyObject) {
        
        self.totalPeopleVoted = totalPeopleVoted + 1
        trainerID.child("totalPeoleVoted").setValue(totalPeopleVoted)
        
        let newtotal = totalRate + Int(starCountLabel.text!)!
        trainerID.child("totalRate").setValue(newtotal)
        
        if commentTextField.text != nil {
            
        let newCommentCount = userCommentCount + 1
        trainerID.child("userCommentsCount").setValue(newCommentCount)
            
        trainerID.child("usersComment").childByAutoId().setValue(["text": commentTextField.text!, "time": FIRServerValue.timestamp() ])
        }
        
        FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("activities_planned").child("sendedPlan").child(nameOfPlan).child("checkVote").setValue(true)
        
        
        
        dismissViewControllerAnimated(true, completion: nil)
        
        print("total" + "\(totalRate)")
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
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
