//
//  ChartViewController.swift
//  HealthyLife
//
//  Created by Dinh Quang Hieu on 8/26/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import JBChartView

class ChartViewController: BaseViewController {

    weak var delegate: BaseScroolViewDelegate?
    
    lazy var infoLabel: UILabel = {
       let label = UILabel()
        return label
    }()
    
    var results:[Result] = [] {
        didSet {
            lineChart.reloadData()
        }
    }
    
    let lineChart = JBLineChartView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lineChart.delegate = self
        lineChart.dataSource = self
        
        self.view.addSubview(lineChart)
        lineChart.frame = CGRect(x: 0, y: 50, width: UIScreen.mainScreen().bounds.width, height: 200)
        
        self.view.addSubview(infoLabel)
        infoLabel.frame = CGRect(x: 50, y: lineChart.frame.origin.y + lineChart.frame.height + 50, width: 100, height: 20)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return UIColor.blueColor()
    }
    
    func lineChartView(lineChartView: JBLineChartView!, didSelectLineAtIndex lineIndex: UInt, horizontalIndex: UInt) {
        print(horizontalIndex)
        infoLabel.text = String(results[Int(horizontalIndex)].currentWeight)
    }
}
