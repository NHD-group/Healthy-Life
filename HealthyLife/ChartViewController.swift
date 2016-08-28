//
//  ChartViewController.swift
//  HealthyLife
//
//  Created by Dinh Quang Hieu on 8/26/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import JBChartView

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
    
    lazy var infoLabel: UILabel = {
       let label = UILabel()
        return label
    }()
    
    var results:[Result] = [] {
        didSet {
            reload()
        }
    }
    
    let lineChart = JBLineChartView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lineChart.delegate = self
        lineChart.dataSource = self
        
        self.view.addSubview(lineChart)
        lineChart.frame = CGRect(x: kJBLineChartViewControllerChartPadding, y: kJBLineChartViewControllerChartTopPadding, width: self.view.bounds.size.width - (kJBLineChartViewControllerChartPadding * 2), height: kJBLineChartViewControllerChartHeight)
        
        self.view.addSubview(infoLabel)
        infoLabel.frame = CGRect(x: 50, y: lineChart.frame.origin.y + lineChart.frame.height + 50, width: 100, height: 20)
        
        // header
        let headerView = JBChartHeaderView(frame: CGRect(x: kJBLineChartViewControllerChartPadding, y: ceil(self.view.bounds.size.height * 0.5) - ceil(kJBLineChartViewControllerChartHeaderHeight * 0.5), width: self.view.bounds.size.width - (kJBLineChartViewControllerChartPadding * 2), height: kJBLineChartViewControllerChartHeaderHeight))
        headerView.titleLabel.text = "Title"
        headerView.titleLabel.textColor = UIColor(red: 28.0/255.0, green: 71.0/255.0, blue: 78.0/255.0, alpha: 1.0)
        headerView.titleLabel.shadowColor = UIColor(white: 1.0, alpha: 0.25)
        headerView.titleLabel.shadowOffset = CGSizeMake(0, 1)
        headerView.subtitleLabel.text = "Sub title"
        headerView.subtitleLabel.textColor = UIColor(red: 28.0/255.0, green: 71.0/255.0, blue: 78.0/255.0, alpha: 1.0)
        headerView.subtitleLabel.shadowColor = UIColor(white: 1.0, alpha: 0.25)
        headerView.subtitleLabel.shadowOffset = CGSizeMake(0, 1)
        headerView.separatorColor = UIColor(red: 142.0/255.0, green: 182.0/255.0, blue: 183.0/255.0, alpha: 1.0)
        self.lineChart.headerView = headerView;
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let isUp = (scrollView.panGestureRecognizer.translationInView(scrollView.superview).y > 0)
        delegate?.pageViewControllerIsMoving(isUp)
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
        print(horizontalIndex)
        infoLabel.text = String(results[Int(horizontalIndex)].currentWeight)
    }
}

extension NSDate {
    func date() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd"
        return dateFormatter.stringFromDate(self)
    }
}
