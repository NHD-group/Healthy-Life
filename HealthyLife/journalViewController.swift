//
//  journalViewController.swift
//  HealthyLife
//
//  Created by admin on 7/27/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Firebase
import TabPageViewController

class journalViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var avaImage: UIImageView!
    
    @IBOutlet weak var weightChangeLabel: UILabel!
    
    @IBOutlet weak var planButton: UIButton!
 
    
    @IBOutlet weak var trackingButton: NHDCustomSubmitButton!
    
    @IBOutlet weak var uploadButton: NHDCustomSubmitButton!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var heightLabel: UILabel!
    
    @IBOutlet weak var followerCountLabel: UILabel!
    
    @IBOutlet weak var settingButton: UIButton!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tableViewResult: UITableView!
    
    var foods = [Food]()
    var results = [Result]()
    var resultRef: FIRDatabaseReference!
    
    let tc = BaseTabPageViewController()
    let vc1 = UIViewController()
    let vc2 = UIViewController()
    
    
    @IBAction func logOutAction(sender: AnyObject) {
        
        Helper.showAlert("Warning", message: "Are you sure you want to log out?", okActionBlock: {
            try! FIRAuth.auth()!.signOut()
            
            NSNotificationCenter.defaultCenter().postNotificationName(Configuration.NotificationKey.userDidLogout, object: nil)
            }, cancelActionBlock: {}, inViewController: self)
        
    }
    
    var currentUserID = DataService.currentUserID
    var currentUserName = DataService.currentUserName
    
    func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = Configuration.Colors.lightGray
    }
    
    func initTableViewResult() {
        tableViewResult.delegate = self
        tableViewResult.dataSource = self
        
        tableViewResult.backgroundColor = Configuration.Colors.lightGray
    }
    
    func loadUser() {
        self.avaImage.layer.cornerRadius = 20
        self.avaImage.clipsToBounds = true
        
        if currentUserID != DataService.currentUserID {
            settingButton.hidden = true
            planButton.hidden = true
            trackingButton.hidden = true
            uploadButton.hidden = true
        }
    }
    
    func setupProfile() {
        //MARK: set up profile
        
        let ref = DataService.BaseRef
        let storageRef = DataService.storageRef
        
        ref.child("users/\(currentUserID)/username").observeEventType(.Value, withBlock: { snapshot in
            self.name.text = snapshot.value as? String
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setValue(snapshot.value as? String, forKey: "currentUserName")
        })
        
        ref.child("users/\(currentUserID)/user_setting").observeEventType(.Value, withBlock: { snapshot in
            if let postDictionary = snapshot.value as? NSDictionary {
                
                ref.child("users").child(self.currentUserID).child("results_journal").observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot!) in
                    
                    let currentWeight = snapshot.value!["CurrentWeight"] as! String
                    let startingWeight = postDictionary["weight changed"] as! String
                    
                    
                    let weightChanged = Double(currentWeight)! - Double(startingWeight)!
                    
                    if weightChanged > 0 {
                        self.weightChangeLabel.text = "gain: \(abs(weightChanged)) kg"
                    } else {
                        self.weightChangeLabel.text = "lose: \(abs(weightChanged)) kg"
                    }
                    
                    
                    
                }
                
                
                self.heightLabel.text = postDictionary["height"] as? String
                self.followerCountLabel.text = "\(postDictionary["followerCount"] as? Int) followers"
                
            } else {
                
                self.avaImage.image = UIImage(named: "defaults")
            }
            
        })
        
        ref.child("users").child(currentUserID).child("followerCount").observeEventType(.Value, withBlock: { snapshot in
            
            if let count = snapshot.value as? Int {
                self.followerCountLabel.text = "\(count) followers"
            }
            
        })
        
        let islandRef = storageRef.child("images/\(currentUserID)")
        avaImage.downloadImageWithImageReference(islandRef)
        
    }
    
    func setupTableViewData() {
        //MARK: Set Up table data
        showLoading()
        let ref = DataService.BaseRef
        ref.child("users").child(currentUserID).child("food_journal").queryLimitedToLast(10).observeEventType(.Value, withBlock: { snapshot in
            
            // The snapshot is a current look at our jokes data.
            
            print(snapshot.value)
            
            self.foods = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    // Make our jokes array for the tableView.
                    
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let food = Food(key: key, dictionary: postDictionary)
                        food.currentID = self.currentUserID
                        
                        // Items are returned chronologically, but it's more fun with the newest jokes first.
                        
                        self.foods.insert(food, atIndex: 0)
                    }
                }
                
            }
            
            // Be sure that the tableView updates when there is new data.
            
            self.tableView.reloadData()
            self.hideLoading()
            self.vc1.view.addSubview(self.tableView)
            let tableViewHeight = UIScreen.mainScreen().bounds.height - (self.topView.frame.origin.y + self.topView.bounds.height) - (self.tabBarController?.tabBar.frame.height)! - 30
            self.tableView.frame = CGRect(x: 0, y: self.tc.option.tabHeight, width: UIScreen.mainScreen().bounds.width, height: tableViewHeight)
        })
        
    }
    
    func setupTableViewResultData() {
        let ref = DataService.BaseRef
        
        
        
        //showLoading()
        
        resultRef = ref.child("users").child(currentUserID).child("results_journal")
        resultRef.queryLimitedToLast(10).observeEventType(.Value, withBlock: { snapshot in
            
            // The snapshot is a current look at our jokes data.
            
            print(snapshot.value)
            
            self.results = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    // Make our jokes array for the tableView.
                    
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let result = Result(key: key, dictionary: postDictionary)
                        
                        
                        // Items are returned chronologically, but it's more fun with the newest jokes first.
                        
                        self.results.insert(result, atIndex: 0)
                    }
                }
                
            }
            
            // Be sure that the tableView updates when there is new data.
            
            self.tableViewResult.reloadData()
            //self.hideLoading()
            self.vc2.view.addSubview(self.tableViewResult)
            let tableViewHeight = UIScreen.mainScreen().bounds.height - (self.topView.frame.origin.y + self.topView.bounds.height) - (self.tabBarController?.tabBar.frame.height)! - 30
            self.tableViewResult.frame = CGRect(x: 0, y: self.tc.option.tabHeight, width: UIScreen.mainScreen().bounds.width, height: tableViewHeight)
        })
        
        tableViewResult.allowsMultipleSelectionDuringEditing = true
    }
    
    func initTabPageView() {
        tc.tabItems = [(vc1, "Food"), (vc2, "Result")]
        
        
        var option = TabPageOption()
        option.currentColor = Configuration.Colors.primary
        option.tabWidth = view.frame.width / CGFloat(tc.tabItems.count)
        tc.option = option
        
        tc.view.frame = CGRect(x: 0, y: topView.frame.origin.y + topView.bounds.height, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height - 130)
        
        self.view.addSubview(tc.view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableView()
        initTableViewResult()
        loadUser()
        
        setupProfile()
        
        
        setupTableViewData()
        setupTableViewResultData()
        
        initTabPageView()
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
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if tableView == self.tableViewResult {
            return true
        }
        return false
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.tableViewResult {
            resultRef.child(results[indexPath.row].resultKey).removeValue()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return foods.count
        } else if tableView == self.tableViewResult {
            return results.count
        }
        return 0
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            if let cell = tableView.dequeueReusableCellWithIdentifier("foodCell") as? FoodTableViewCell {
                
                // Send the single joke to configureCell() in JokeCellTableViewCell.
                
                cell.configureCell(foods[indexPath.row])
                
                return cell
                
            } else {
                
                return FoodTableViewCell()
                
            }
        } else if tableView == self.tableViewResult {
            let cell = tableView.dequeueReusableCellWithIdentifier("result") as! displayCellTableViewCell
            cell.result = results[indexPath.row]
            return cell
            
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    @IBAction func onAddButtonPressed(sender: UIBarButtonItem) {
        if let index = tc.currentIndex {
            if index == 0 {
                self.performSegueWithIdentifier("uploadFood", sender: self)
                //let vc = uploadFoodViewController()
                
                //self.navigationController?.pushViewController(vc, animated: true)
            } else if index == 1 {
                self.performSegueWithIdentifier("updateResult", sender: self)
                //let vc = uploadResultViewController()
                //self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

}

