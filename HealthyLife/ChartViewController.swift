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

class ChartViewController: BaseViewController {
    
    weak var delegate: BaseScroolViewDelegate?
    
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
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    var infoView: UIView!
    
    var results:[Result] = [] {
        didSet {
            reload()
        }
    }
    
    let lineChart = JBLineChartView()
    var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storageRef = FIRStorage.storage().reference()
        
        lineChart.delegate = self
        lineChart.dataSource = self
        
        scrollView = UIScrollView(frame: view.frame)
        scrollView.alwaysBounceVertical = true
        scrollView.delegate = self
        view.addSubview(scrollView)
        scrollView.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        scrollView.addSubview(lineChart)
        lineChart.frame = CGRect(x: kJBLineChartViewControllerChartPadding, y: kJBLineChartViewControllerChartTopPadding, width: self.view.bounds.size.width - (kJBLineChartViewControllerChartPadding * 2), height: kJBLineChartViewControllerChartHeight)
        
        // header
        let headerView = JBChartHeaderView(frame: CGRect(x: kJBLineChartViewControllerChartPadding, y: ceil(self.view.bounds.size.height * 0.5) - ceil(kJBLineChartViewControllerChartHeaderHeight * 0.5), width: self.view.bounds.size.width - (kJBLineChartViewControllerChartPadding * 2), height: kJBLineChartViewControllerChartHeaderHeight))
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
        
        infoView = UIView(frame: CGRect(x: 0, y: lineChart.frame.origin.y + lineChart.frame.height, width: self.view.bounds.width, height: 120))
        scrollView.addSubview(infoView)
        scrollView.contentSize = CGSizeMake(view.bounds.width, CGRectGetMaxY(infoView.frame))
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
        
        self.infoView.addSubview(imageView)
        imageView.snp_makeConstraints { (make) in
            make.height.equalTo(80)
            make.width.equalTo(80)
            make.left.equalTo(self.infoView).offset(20)
            make.top.equalTo(self.infoView).offset(20)
        }
        
        self.infoView.addSubview(weightLabel)
        weightLabel.snp_makeConstraints { (make) in
            make.left.equalTo(self.imageView.snp_right).offset(10)
            make.top.equalTo(self.imageView).offset(10)
        }
        
        self.infoView.addSubview(timeLabel)
        timeLabel.snp_makeConstraints { (make) in
            make.right.equalTo(self.infoView).offset(-20)
            make.bottom.equalTo(self.imageView)
        }
    }
    
    func reload() {
        lineChart.reloadData()
        
        let footerView = JBLineChartFooterView(frame: CGRect(x: kJBLineChartViewControllerChartPadding, y: kJBLineChartViewControllerChartTopPadding, width: ceil(self.view.bounds.size.height * 0.5) - ceil(kJBLineChartViewControllerChartFooterHeight * 0.5), height: kJBLineChartViewControllerChartFooterHeight))
        footerView.backgroundColor = UIColor.clearColor()
        if results.count > 0 {
            footerView.rightLabel.text = results[0].time.date()
            footerView.leftLabel.text = results[results.count - 1].time.date()
        }
        footerView.leftLabel.textColor = Configuration.Colors.brightRed
        footerView.rightLabel.textColor = Configuration.Colors.brightRed
        footerView.sectionCount = results.count
        footerView.footerSeparatorColor = Configuration.Colors.primary
        self.lineChart.footerView = footerView;
    }
}

extension ChartViewController: JBLineChartViewDelegate, JBLineChartViewDataSource {
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
        UIView.animateWithDuration(Configuration.animationDuration) { 
            
            self.imageView.downloadImageWithKey(result.resultKey)
            self.weightLabel.text = "\(result.currentWeight) kg"
            self.timeLabel.text = result.time.dateTime()
            self.infoView.backgroundColor = Configuration.Colors.lightGray
        }
    }
}

extension ChartViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let isUp = (scrollView.panGestureRecognizer.translationInView(scrollView.superview).y > 0)
        delegate?.pageViewControllerIsMoving(isUp)
    }
}

extension NSDate {
    func date() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd"
        return dateFormatter.stringFromDate(self)
    }
    
    func dateTime() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.stringFromDate(self)
        
    }
}
