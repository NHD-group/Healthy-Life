//
//  journalViewController.swift
//  HealthyLife
//
//  Created by admin on 7/27/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Firebase

class journalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var avaImage: UIImageView!
    
    @IBOutlet weak var weightChangeLabel: UILabel!
    
    @IBOutlet weak var planButton: UIButton!
    
    @IBOutlet weak var DOB: UILabel!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var heightLabel: UILabel!
    
    @IBOutlet weak var followerCountLabel: UILabel!
    
    @IBOutlet weak var settingButton: UIButton!
    
     var foods = [Food]()
    
    @IBAction func logOutAction(sender: AnyObject) {
        try! FIRAuth.auth()!.signOut()
        
        NSNotificationCenter.defaultCenter().postNotificationName(Configuration.userDidLogoutNotificationKey, object: nil)
    }
    
    var currentUserID = DataService.currentUserID
    var currentUserName = DataService.currentUserName
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        self.avaImage.layer.cornerRadius = 20
        self.avaImage.clipsToBounds = true
        
        if currentUserID != DataService.currentUserID {
            settingButton.hidden = true
            planButton.hidden = true
        }
        
//        self.name.text = currentUserName
 
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
                        
                        self.weightChangeLabel.text = "changed: \(postDictionary["weight changed"] as! String)"
                        self.DOB.text = postDictionary["DOB"] as? String
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
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        islandRef.dataWithMaxSize((1 * 1024 * 1024)/2) { (data, error) -> Void in
            if (error != nil) {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                print("it workss")
                let AvaImage: UIImage! = UIImage(data: data!)
                self.avaImage.image = AvaImage
                }
        }

        
        
        //MARK: Set Up table data
        
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
//            MBProgressHUD.hideHUDForView(self.view, animated: true)
        })

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foods.count
        
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("foodCell") as? FoodTableViewCell {
            
            // Send the single joke to configureCell() in JokeCellTableViewCell.
            
            cell.configureCell(foods[indexPath.row])
            
            return cell
            
        } else {
            
            return FoodTableViewCell()
            
        }
        
        
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
