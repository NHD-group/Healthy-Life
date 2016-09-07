//
//  weeklyPlanViewController.swift
//  HealthyLife
//
//  Created by admin on 8/1/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Firebase

class weeklyPlanViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
   
    
    var yourPlans = [String]()
    var sendedPlans = [String]()
    
    
    let  HeaderViewIdentifier = "yourPlan"
    let  headerViewIdentifier = "sendedPlan"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: HeaderViewIdentifier)
        tableView.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: headerViewIdentifier)
        
        showLoading()
        FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("activities_planned")
            .child("yourPlan").observeEventType(.Value, withBlock: { snapshot in
                
                
                
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    
                    self.yourPlans = []
                    
                    for snap in snapshots {
                        
                        let key = snap.key
                        
                        self.yourPlans.insert(key, atIndex: 0)
                    }
                    
                }
                
                // Be sure that the tableView updates when there is new data.
                
                self.tableView.reloadData()
                self.hideLoading()
                
            })
        
                FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("activities_planned")
            .child("sendedPlan").observeEventType(.Value, withBlock: { snapshot in
            
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
              
                    self.sendedPlans = []
                    
                    for snap in snapshots {
                        
                        let key = snap.key
                        
                        self.sendedPlans.insert(key, atIndex: 0)
                        
                    }
                    
                }
                
                // Be sure that the tableView updates when there is new data.
                
                self.tableView.reloadData()
                self.hideLoading()
                
            })
        
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: TableView: Set Up
    
    
    //MARK: Number of Section
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
        
    }
    
    //MARK: Number of Row Set Up
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return yourPlans.count
            
        case 1:
            return sendedPlans.count
            
            
        default: return 0
        }
    }
    
    //MARK: Header Set up
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch section {
        case 0:
            
            let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(HeaderViewIdentifier)! as UITableViewHeaderFooterView
            
            header.textLabel?.text = "Self Create Plan"
            
            return header
            
        case 1:
            let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(headerViewIdentifier)! as UITableViewHeaderFooterView
            
            header.textLabel?.text = "Trainer Created Plan "
            
            return header
            
            
        default: return UIView()
            
        }
    }
    
    
    
    //MARK: Set Up the display of cell
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            // Deal
            
        case 0:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("yourPlan") as! cellTableViewCell
            cell.plan = yourPlans[indexPath.row]
           
            
            return cell
            // Distance
            
        case 1:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("sendedPlan") as! sendedPlanCellTableViewCell
            cell.plan = sendedPlans[indexPath.row]
           
            return cell
            // Sort
            
            
            
            
            
        default:
            return UITableViewCell()
        }
        
    }
    
    
    //*******************************
    
    
    
   
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        
        
        
        if segue.identifier == "send"
        {
            let controller = segue.destinationViewController as! sendPlanViewController
            if let button = sender as? UIButton {
                let cell = button.superview?.superview as! cellTableViewCell
                controller.nameOfPlan = cell.plan
            }
        } else if segue.identifier == "rate" {
            let controller = segue.destinationViewController as! ratingViewController
            if let button = sender as? UIButton {
                let cell = button.superview?.superview as! sendedPlanCellTableViewCell
                controller.KeyUID = cell.keyUID
                controller.nameOfPlan = cell.plan
            }
        } else if segue.identifier == "yourPlan" {
            
        
            let targetController = segue.destinationViewController as! dailyPlanViewController
            
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let key = yourPlans[(indexPath?.row)!]
            targetController.key = key
            targetController.segue = "yourPlan"
            
        } else if segue.identifier == "sendedPlan" {
            
            
            let targetController = segue.destinationViewController as! dailyPlanViewController
            
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let key = sendedPlans[(indexPath?.row)!]
            targetController.key = key
            targetController.segue = "sendedPlan"
            
        } else if let vc = segue.destinationViewController as? SchedulePlanViewController {
            if let button = sender as? UIButton {
                if let cell = button.superview?.superview as? sendedPlanCellTableViewCell {
                vc.PlanName = cell.plan
                } else if let yourCell = button.superview?.superview as? cellTableViewCell {
                vc.PlanName = yourCell.plan
                }
            }
        }
    }
    
}
