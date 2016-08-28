//
//  FoodCollectionViewCell.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 25/8/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import Firebase
import NSDate_TimeAgo

protocol FoodCollectionViewCellDelegate: class {
    func buyItem(food: Food, price: Int)
}

class FoodCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var foodImageView: UIImageView!
    
    @IBOutlet weak var desLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var loveCount: UILabel!
    
    @IBOutlet weak var backview: UIView!
    
    @IBOutlet weak var loveImage: UIImageView!
    
    @IBOutlet weak var buyButton: NHDCustomSubmitGreenButton!
    
    weak var delegate: FoodCollectionViewCellDelegate?

    let storageRef = FIRStorage.storage().reference()
    var loveRef = FIRDatabaseReference()
    var ref =  FIRDatabase.database().reference()
    let currentUserID = FIRAuth.auth()?.currentUser?.uid
    
    var food: Food!
    
    func configureCell(food : Food) {
        
        self.food = food
                
        backview.layer.cornerRadius = 10
        backview.clipsToBounds = true
        
        
        desLabel.text = food.foodDes ?? ""
        if let time = food.time {
            timeLabel.text = "\(time.timeAgo())"
        } else {
            timeLabel.text = ""
        }
        loveCount.text = "\(food.love)"
        
        
        let islandRef = storageRef.child("images/\(food.foodKey)")
        foodImageView.downloadImageWithImageReference(islandRef)
        
        loveRef = ref.child("users").child(currentUserID!).child("votesLove").child(food.foodKey)
        
        loveRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let thumbsUpDown = snapshot.value as? NSNull {
                
                // Current user hasn't voted for the joke... yet.
                
                print(thumbsUpDown)
                self.loveImage.image = UIImage(named: "love")
            } else {
                
                // Current user voted for the joke!
                
                self.loveImage.image = UIImage(named: "loved")
                
            }
            
        })
        
    }
    
    func loveTapped(sender: UITapGestureRecognizer) {
        
        // observeSingleEventOfType listens for a tap by the current user.
        
        loveRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let thumbsUpDown = snapshot.value as? NSNull {
                print(thumbsUpDown)
                self.loveImage.image = UIImage(named: "love")
                
                // addSubtractVote(), in Joke.swift, handles the vote.
                
                self.food.addSubtractLove(true)
                // setValue saves the vote as true for the current user.
                // voteRef is a reference to the user's "votes" path.
                
                self.loveRef.setValue(true)
            } else {
                self.loveImage.image = UIImage(named: "loved")
                self.food.addSubtractLove(false)
                self.loveRef.removeValue()
            }
            
        })
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // UITapGestureRecognizer is set programatically.
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(FoodTableViewCell.loveTapped(_:)))
        tap.numberOfTapsRequired = 1
        loveImage.addGestureRecognizer(tap)
        loveImage.userInteractionEnabled = true
        
        let price = rand() % 300 + 50
        buyButton.tag = Int(price)
        buyButton.setTitle(String.localizedStringWithFormat(" Buy $%0.02f ", Double(price)/100.0), forState: .Normal)
    }
    
    @IBAction func onBuy(button: UIButton) {
        
        let price = button.tag
        
        delegate?.buyItem(food, price: price)
    }
    
}