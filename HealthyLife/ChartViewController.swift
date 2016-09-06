//
//  ChartViewController.swift
//  HealthyLife
//
//  Created by Dinh Quang Hieu on 8/26/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import JBChartView
import Firebase
import SnapKit

let kJBLineChartViewControllerChartHeight:CGFloat = 250.0
let kJBLineChartViewControllerChartPadding:CGFloat = 10.0
let kJBLineChartViewControllerChartTopPadding:CGFloat = 50.0
let kJBLineChartViewControllerChartHeaderHeight:CGFloat = 75.0
let kJBLineChartViewControllerChartHeaderPadding:CGFloat = 20.0
let kJBLineChartViewControllerChartFooterHeight:CGFloat = 20.0
let kJBLineChartViewControllerChartSolidLineWidth:CGFloat = 6.0
let kJBLineChartViewControllerChartSolidLineDotRadius:CGFloat = 5.0
let kJBLineChartViewControllerChartDashedLineWidth:CGFloat = 2.0
let kJBLineChartViewControllerMaxNumChartPoints:UInt = 7

protocol ChartViewControllerDelegate: class {
    func didSelectResult(result: Result)
}

class ChartViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: BaseScroolViewDelegate?
    
    weak var chartViewControllerDelegate: ChartViewControllerDelegate?
    
    var tableView: UITableView!
    
    var results:[Result] = []
    var selectedResultIndex = -1
    var foods:[Food] = []
    var filterFoods:[Food] = []
    var activitiesDone:[ActivitiesDone] = []
    var filterActivities:[ActivitiesDone] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - 120))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        
        self.view.addSubview(tableView)
        tableView.reloadData()
        
        loadActivities()
    }
    
    func loadActivities() {
        DataService.dataService.userRef.child("activityDone").observeEventType(.Value, withBlock: { snapshot in
            self.activitiesDone = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    // Make our jokes array for the tableView.
                    
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let activity = ActivitiesDone(key: key, dictionary: postDictionary)
                        
                        
                        // Items are returned chronologically, but it's more fun with the newest jokes first.
                        
                        self.activitiesDone.insert(activity, atIndex: 0)
                    }
                }
                
            }
            
            // Be sure that the tableView updates when there is new data.
            
            
            
            
        })
        
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return filterFoods.count
        } else if section == 3 {
            return filterActivities.count
        }
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return ""
        case 1:
            return "RESULT"
        case 2:
            return "FOOD"
        case 3:
            return "ACTIVITIES DONE"
        default:
            return ""
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return kJBLineChartViewControllerChartHeight + kJBLineChartViewControllerChartHeaderHeight + kJBLineChartViewControllerChartFooterHeight
        } else if indexPath.section == 1 {
            return 200
        } else if indexPath.section == 2 {
            return 110
        }
        return 110
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let chartViewCell = ChartViewCell()
            chartViewCell.setup()
            chartViewCell.results = self.results
            chartViewCell.delegate = self
            return chartViewCell
        } else if indexPath.section == 1 {
            let resultCell = ResultCell()
            resultCell.setup()
            self.chartViewControllerDelegate = resultCell
            if selectedResultIndex != -1 {
                resultCell.didSelectResult(results[selectedResultIndex])
            }
            return resultCell
        } else if indexPath.section == 2 {
            let cell = FoodCell()
            cell.setup()
            cell.food = filterFoods[indexPath.row]
            return cell
        } else if indexPath.section == 3 {
            let cell = ActivityDoneCell()
            cell.setup()
            cell.activity = filterActivities[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        BaseTabPageViewController.scrollViewDidScroll(scrollView, delegate: delegate)
    }
}

extension ChartViewController: ChartViewCellDelegate {
    func didSelectResult(result: Result) {
        
        filterFoods = foods.filter({ (food: Food) -> Bool in
            //food.time?.date() == result.time.date()
            food.time?.timeAgo() == result.time.timeAgo() || food.time?.date() == result.time.date()
        })
        
        self.tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: UITableViewRowAnimation.Automatic)
        
        chartViewControllerDelegate?.didSelectResult(result)
        
        selectedResultIndex = results.indexOf({ (res: Result) -> Bool in
            res.time.dateTime() == result.time.dateTime()
        })!
        
        filterActivities = activitiesDone.filter({ (activity: ActivitiesDone) -> Bool in
            //activity.time!.date() == result.time.date()
            activity.time?.timeAgo() == result.time.timeAgo() || activity.time?.date() == result.time.date()
        })
        
        self.tableView.reloadSections(NSIndexSet(index: 3), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
}

class ChartViewCell: UITableViewCell {
    weak var delegate: ChartViewCellDelegate?
    
    var storageRef:FIRStorageReference!
    
    var results:[Result] = [] {
        didSet {
            reload()
        }
    }
    
    let lineChart = JBLineChartView()
    
    func setup() {
        self.selectionStyle = .None
        self.accessoryType = .None
        
        storageRef = FIRStorage.storage().reference()
        
        lineChart.delegate = self
        lineChart.dataSource = self
        
        self.contentView.addSubview(lineChart)
        lineChart.frame = CGRect(x: kJBLineChartViewControllerChartPadding, y: kJBLineChartViewControllerChartTopPadding, width: UIScreen.mainScreen().bounds.width - (kJBLineChartViewControllerChartPadding * 2), height: kJBLineChartViewControllerChartHeight)
        
        // header
        let headerView = JBChartHeaderView(frame: CGRect(x: kJBLineChartViewControllerChartPadding, y: ceil(self.contentView.bounds.size.height * 0.5) - ceil(kJBLineChartViewControllerChartHeaderHeight * 0.5), width: UIScreen.mainScreen().bounds.width - (kJBLineChartViewControllerChartPadding * 2), height: kJBLineChartViewControllerChartHeaderHeight))
        headerView.titleLabel.text = "Your weight"
        headerView.titleLabel.textColor = UIColor(red: 28.0/255.0, green: 71.0/255.0, blue: 78.0/255.0, alpha: 1.0)
        headerView.titleLabel.shadowColor = UIColor(white: 1.0, alpha: 0.25)
        headerView.titleLabel.shadowOffset = CGSizeMake(0, 1)
        headerView.subtitleLabel.text = ""
        headerView.subtitleLabel.textColor = UIColor(red: 28.0/255.0, green: 71.0/255.0, blue: 78.0/255.0, alpha: 1.0)
        headerView.subtitleLabel.shadowColor = UIColor(white: 1.0, alpha: 0.25)
        headerView.subtitleLabel.shadowOffset = CGSizeMake(0, 1)
        headerView.separatorColor = UIColor(red: 142.0/255.0, green: 182.0/255.0, blue: 183.0/255.0, alpha: 1.0)
        self.lineChart.headerView = headerView;
    }
    
    func reload() {
        lineChart.reloadData()
        
        let footerView = JBLineChartFooterView(frame: CGRect(x: kJBLineChartViewControllerChartPadding, y: kJBLineChartViewControllerChartTopPadding, width: ceil(UIScreen.mainScreen().bounds.width * 0.5) - ceil(kJBLineChartViewControllerChartFooterHeight * 0.5), height: kJBLineChartViewControllerChartFooterHeight))
        footerView.backgroundColor = UIColor.clearColor()
        if results.count > 0 {
            footerView.rightLabel.text = results[results.count - 1].time.date()
            footerView.leftLabel.text = results[0].time.date()
        }
        footerView.leftLabel.textColor = Configuration.Colors.brightRed
        footerView.rightLabel.textColor = Configuration.Colors.brightRed
        footerView.sectionCount = results.count
        footerView.footerSeparatorColor = Configuration.Colors.primary
        self.lineChart.footerView = footerView;
    }
}

protocol ChartViewCellDelegate: class {
    func didSelectResult(result: Result)
}

extension ChartViewCell: JBLineChartViewDelegate, JBLineChartViewDataSource {
    func numberOfLinesInLineChartView(lineChartView: JBLineChartView!) -> UInt {
        return 1
    }
    
    func lineChartView(lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
        return UInt(results.count)
    }
    
    func lineChartView(lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        let currentWeightStr = results[Int(horizontalIndex)].currentWeight
        if let n = NSNumberFormatter().numberFromString(currentWeightStr) {
            return CGFloat(n)
        }
        return 0
    }
    
    func lineChartView(lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return Configuration.Colors.brightRed
    }
    
    func lineChartView(lineChartView: JBLineChartView!, lineStyleForLineAtLineIndex lineIndex: UInt) -> JBLineChartViewLineStyle {
        return .Dashed
    }
    
    func lineChartView(lineChartView: JBLineChartView!, showsDotsForLineAtLineIndex lineIndex: UInt) -> Bool {
        return true
    }
    
    func lineChartView(lineChartView: JBLineChartView!, widthForLineAtLineIndex lineIndex: UInt) -> CGFloat {
        return kJBLineChartViewControllerChartDashedLineWidth
    }
    
    func lineChartView(lineChartView: JBLineChartView!, dotRadiusForDotAtHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        return kJBLineChartViewControllerChartSolidLineDotRadius
    }
    
    func lineChartView(lineChartView: JBLineChartView!, colorForDotAtHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> UIColor! {
        return Configuration.Colors.primary
    }
    
    func lineChartView(lineChartView: JBLineChartView!, didSelectLineAtIndex lineIndex: UInt, horizontalIndex: UInt) {
        let result = results[Int(horizontalIndex)]
        delegate?.didSelectResult(result)
    }
}

class ResultCell: UITableViewCell, ChartViewControllerDelegate {
    var storageRef:FIRStorageReference!
    
    lazy var weightLabel: UILabel = {
        let label = UILabel()
        label.font = NHDFontBucket.fontWithSize(20)
        label.textColor = Configuration.Colors.primary
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = NHDFontBucket.fontWithSize(14)
        label.textColor = Configuration.Colors.brightRed
        return label
    }()
    
    lazy var resultImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    var infoView: UIView!
    
    func setup() {
        self.accessoryType = .None
        
        storageRef = FIRStorage.storage().reference()
        
        infoView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 200))
        infoView.backgroundColor = Configuration.Colors.lightGray
        
        self.contentView.backgroundColor = Configuration.Colors.lightGray
        self.backgroundColor = Configuration.Colors.lightGray
        self.contentView.addSubview(infoView)
        
        self.infoView.addSubview(resultImageView)
        resultImageView.snp_makeConstraints { (make) in
            make.height.equalTo(180)
            make.width.equalTo(180)
            make.left.equalTo(self.infoView).offset(10)
            make.top.equalTo(self.infoView).offset(10)
        }
        
        self.infoView.addSubview(weightLabel)
        weightLabel.snp_makeConstraints { (make) in
            make.left.equalTo(self.resultImageView.snp_right).offset(10)
            make.top.equalTo(self.resultImageView).offset(10)
        }
        
        self.infoView.addSubview(timeLabel)
        timeLabel.snp_makeConstraints { (make) in
            make.right.equalTo(self.infoView).offset(-20)
            make.bottom.equalTo(self.resultImageView)
        }
    }
    
    func didSelectResult(result: Result) {
        let imageRef = storageRef.child("images/\(result.resultKey)")
        self.resultImageView.downloadImageWithImageReference(imageRef)
        self.weightLabel.text = "\(result.currentWeight) kg"
        self.timeLabel.text = result.time.dateTime()
    }
}

class FoodCell: UITableViewCell {
    var storageRef:FIRStorageReference!
    var loveRef:FIRDatabaseReference!
    
    lazy var foodImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.layer.cornerRadius = 10
        return imgView
    }()
    
    lazy var loveImageView: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "love"))
        return imgView
    }()
    
    lazy var foodDesLabel: UILabel = {
        let label = UILabel()
        label.font = NHDFontBucket.fontWithSize(20)
        label.textColor = Configuration.Colors.primary
        label.numberOfLines = 0
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = NHDFontBucket.fontWithSize(14)
        label.textColor = Configuration.Colors.brightRed
        return label
    }()
    
    lazy var loveCountLabel: UILabel = {
        let label = UILabel()
        label.font = NHDFontBucket.fontWithSize(14)
        label.textColor = Configuration.Colors.brightRed
        return label
    }()
    
    var infoView: UIView!
    
    var food: Food! {
        didSet {
            let islandRef = storageRef.child("images/\(food.foodKey)")
            //foodImageView.downloadImageWithImageReference(islandRef)
            
            foodImageView.downloadImageWithImageReference(islandRef) { (image) in
                self.foodImageView.layer.cornerRadius = 5
            }
            
            loveCountLabel.text = "\(food.love)"
            
            foodDesLabel.text = food.foodDes
            
            if let time = food.time {
                timeLabel.text = "\(time.timeAgo())"
            } else {
                timeLabel.text = ""
            }
        }
    }
    
    func setup() {
        self.accessoryType = .None
        
        storageRef = FIRStorage.storage().reference()
        loveRef = FIRDatabaseReference()
        
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 110))
        backView.backgroundColor = Configuration.Colors.lightGray
        self.contentView.addSubview(backView)
        
        infoView = UIView(frame: CGRect(x: 8, y: 5, width: UIScreen.mainScreen().bounds.width - 16, height: 100))
        infoView.layer.cornerRadius = 10
        infoView.backgroundColor = UIColor.whiteColor()
        self.contentView.addSubview(infoView)
        
        self.infoView.addSubview(foodImageView)
        foodImageView.snp_makeConstraints { (make) in
            make.height.equalTo(80)
            make.width.equalTo(80)
            make.left.equalTo(self.infoView).offset(10)
            make.top.equalTo(self.infoView).offset(10)
        }
        
        self.infoView.addSubview(foodDesLabel)
        foodDesLabel.snp_makeConstraints { (make) in
            make.top.equalTo(foodImageView)
            make.left.equalTo(foodImageView.snp_right).offset(20)
            make.right.greaterThanOrEqualTo(self.infoView).offset(-20)
        }
        
        self.infoView.addSubview(loveImageView)
        loveImageView.snp_makeConstraints { (make) in
            make.top.equalTo(self.foodDesLabel.snp_bottom).offset(10)
            make.left.equalTo(self.foodDesLabel)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        
        self.infoView.addSubview(loveCountLabel)
        loveCountLabel.snp_makeConstraints { (make) in
            make.centerY.equalTo(self.loveImageView)
            make.left.equalTo(self.loveImageView.snp_right).offset(8)
        }
        
        self.infoView.addSubview(timeLabel)
        timeLabel.snp_makeConstraints { (make) in
            make.right.equalTo(self.infoView).offset(-20)
            make.bottom.equalTo(self.foodImageView)
        }
    }
    
    
}

class ActivityDoneCell: UITableViewCell {
    var activity: ActivitiesDone! {
        didSet {
            timeLabel.text = "\(activity.time!.timeAgo())"
            activityNameLabel.text = "Exercise : " + (activity.activityName)!
            nameOfPlanLabel.text = "Plan : " + (activity?.nameOfPlan)!
        }
    }
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.grayColor()
        label.font = NHDFontBucket.fontWithSize(14)
        return label
    }()
    
    lazy var separatorView1: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 50, width: UIScreen.mainScreen().bounds.width, height: 2))
        view.backgroundColor = Configuration.Colors.lightGray
        return view
    }()
    
    lazy var separatorView2: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 50, width: UIScreen.mainScreen().bounds.width, height: 2))
        view.backgroundColor = Configuration.Colors.lightGray
        return view
    }()
    
    lazy var activityNameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var nameOfPlanLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFontOfSize(17)
        return label
    }()
    
    var infoView: UIView!
    
    func setup() {
        self.accessoryType = .None
        
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 110))
        backView.backgroundColor = Configuration.Colors.lightGray
        self.contentView.addSubview(backView)
        
        infoView = UIView(frame: CGRect(x: 8, y: 5, width: UIScreen.mainScreen().bounds.width - 16, height: 100))
        infoView.layer.cornerRadius = 10
        infoView.backgroundColor = UIColor.whiteColor()
        self.contentView.addSubview(infoView)
        
        self.infoView.addSubview(timeLabel)
        timeLabel.snp_makeConstraints { (make) in
            make.left.equalTo(self.infoView).offset(10)
            make.top.equalTo(self.infoView).offset(10)
        }
        
        self.infoView.addSubview(separatorView1)
        separatorView1.snp_makeConstraints { (make) in
            make.top.equalTo(self.timeLabel.snp_bottom)
            make.left.equalTo(self.timeLabel)
        }
        
        self.infoView.addSubview(activityNameLabel)
        activityNameLabel.snp_makeConstraints { (make) in
            make.top.equalTo(self.separatorView1.snp_bottom).offset(8)
            make.left.equalTo(self.timeLabel)
        }
        
        self.infoView.addSubview(separatorView2)
        separatorView2.snp_makeConstraints { (make) in
            make.top.equalTo(self.activityNameLabel.snp_bottom)
            make.left.equalTo(self.timeLabel)
        }
        
        self.infoView.addSubview(nameOfPlanLabel)
        nameOfPlanLabel.snp_makeConstraints { (make) in
            make.top.equalTo(self.separatorView2.snp_bottom).offset(8)
            make.left.equalTo(self.timeLabel)
        }
    }
    
    
    
}

extension NSDate {
    func date() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        return dateFormatter.stringFromDate(self)
    }
    
    func dateTime() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        return dateFormatter.stringFromDate(self)
        
    }
}
