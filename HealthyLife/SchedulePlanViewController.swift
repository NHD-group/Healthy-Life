//
//  SchedulePlanViewController.swift
//  HealthyLife
//
//  Created by admin on 8/29/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit

class SchedulePlanViewController:  BaseViewController {

    @IBOutlet weak var nameOfPlan: UILabel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    @IBAction func saveScheduleAction(sender: AnyObject) {
        let notification = UILocalNotification()
        notification.fireDate = datePicker.date
        notification.alertBody = "Hey you! Yeah you! start your work out \(PlanName) "
        notification.alertAction = "be awesome!"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["CustomField1": "w00t"]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        onBack()
    }
    
    var PlanName = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameOfPlan.text = PlanName
        // Do any additional setup after loading the view.
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
