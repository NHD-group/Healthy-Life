//
//  displayFoodViewController.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 25/8/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import CollectionViewWaterfallLayout
import SnapKit
import Firebase


class displayFoodViewController: BaseViewController {
    
    var collectionView: UICollectionView!
    weak var delegate: BaseScroolViewDelegate?
    
    var foods = [Food]()
    var currentUserID = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        getFoodData()
    }
    
    func setupCollectionView() {
        
        let layout = CollectionViewWaterfallLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.headerInset = UIEdgeInsetsMake(20, 0, 0, 0)
        layout.headerHeight = 50
        layout.footerHeight = 20
        layout.minimumColumnSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        
        collectionView.backgroundColor = Configuration.Colors.lightGray
        view.addSubview(collectionView)
        collectionView.snp_makeConstraints { (make) in
            make.edges.equalTo(view.snp_edges)
        }
        
        collectionView.collectionViewLayout = layout
        collectionView.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: CollectionViewWaterfallElementKindSectionHeader, withReuseIdentifier: "Header")
        collectionView.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: CollectionViewWaterfallElementKindSectionFooter, withReuseIdentifier: "Footer")
        collectionView.registerNib(UINib(nibName: String(FoodCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: String(FoodCollectionViewCell))
    }
    
    func getFoodData() {
        
        showLoading()
        let ref = DataService.BaseRef
        ref.child("users").child(currentUserID).child("food_journal").queryLimitedToLast(10).observeEventType(.Value, withBlock: { snapshot in
            
            self.foods = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    
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
            self.collectionView.reloadData()
            self.hideLoading()
        })
    }
}

extension displayFoodViewController: UICollectionViewDataSource, CollectionViewWaterfallLayoutDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foods.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
  
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(FoodCollectionViewCell), forIndexPath: indexPath) as! FoodCollectionViewCell
        cell.configureCell(foods[indexPath.row])
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableView: UICollectionReusableView? = nil
        
        if kind == CollectionViewWaterfallElementKindSectionHeader {
            reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Header", forIndexPath: indexPath)
        }
        else if kind == CollectionViewWaterfallElementKindSectionFooter {
            reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Footer", forIndexPath: indexPath)
        }
        
        return reusableView!
    }
    
    // MARK: WaterfallLayoutDelegate
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = UIScreen.mainScreen().bounds.width / 2.1
        var height: CGFloat = 210
        
        let food = foods[indexPath.row]
        if let text = food.foodDes {
             height += NHDFontBucket.blackFontWithSize(16).heightOfString(text, constrainedToWidth: Double(width))
        }

        if indexPath.row == 0 {
            height += 10
        }
        
        return CGSizeMake(width, height)
    }

    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, heightForHeaderInSection section: Int) -> Float {
        return 15
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, heightForFooterInSection section: Int) -> Float {
        return 100
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        BaseTabPageViewController.scrollViewDidScroll(scrollView, delegate: delegate)
    }
}
