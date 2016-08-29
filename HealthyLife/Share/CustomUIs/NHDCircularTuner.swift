//
//  NHDCircularTuner.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 29/8/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit

class NHDCircularTuner: UIControl {
    
    var progress: Float = 0.0 {
        didSet {
            sendActionsForControlEvents(.ValueChanged)
            setNeedsDisplay()
        }
    }
    var lineCount: NSInteger = 0
    var completeColor: UIColor?
    var incompleteColor: UIColor?
    var image: UIImage? {
        didSet {
            setupImageView()
            setupLines()
        }
    }
    var flipped = false
    var imageView: UIImageView?
    var lines = [CAShapeLayer]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        baseInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        baseInit()
    }
    
    func baseInit() {
        progress = 1.0;
        lineCount = 15;
        completeColor = Configuration.Colors.veryYellow
        incompleteColor = Configuration.Colors.softCyan
        backgroundColor = UIColor.clearColor()
        setupGR()
    }
    
    func setupGR() {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.handleGR(_:)))
        addGestureRecognizer(tapGR)
        
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(self.handleGR(_:)))
        addGestureRecognizer(panGR)

    }
    
    func handleGR(gesture: UIGestureRecognizer) {
        
        let location = gesture.locationInView(self)
        progress = Float(bounds.size.height - location.y) / Float(bounds.size.height)
        
        notifyStateChanged(gesture.state)
    }

    func notifyStateChanged(state: UIGestureRecognizerState) {
        switch (state) {
        case .Began:
            sendActionsForControlEvents(.EditingDidBegin)
            break
        case .Ended, .Cancelled:
            sendActionsForControlEvents(.EditingDidEnd)
            break
        default:
            break
        }
    }
    
    func setupImageView() {
        
        imageView = UIImageView()
        imageView!.image = image
        imageView!.layer.zPosition = 2
        addSubview(imageView!)
        
        let imageViewPositionX = flipped ? (bounds.size.width - bounds.size.width/4) : bounds.size.width/4
        let imageViewPosition = CGPointMake(imageViewPositionX, bounds.size.height/2)
        let imageViewSize = bounds.size.height/4
        imageView!.frame = CGRectMake(0, 0, imageViewSize, imageViewSize);
        imageView!.center = imageViewPosition;
    }

    func setupLines() {
        
        for i in  0...lineCount {
            let line = CAShapeLayer()
            let path = UIBezierPath(rect: CGRectMake(0, 0, 2, bounds.size.width - bounds.size.width/3))
            line.path = path.CGPath
            line.bounds = CGPathGetBoundingBox(path.CGPath)
            
            line.lineWidth = 3
            line.fillColor = UIColor.clearColor().CGColor
            
            line.strokeStart = 0.87
            line.strokeEnd = 1.0
            
            line.anchorPoint = CGPointMake(0.5, 1)
            
            let linePositionX = flipped ? (bounds.size.width - bounds.size.width/4) : bounds.size.width/4;
            line.position = CGPointMake(linePositionX, bounds.size.height/2)
            
            var distance = CGFloat(M_PI) / CGFloat(lineCount-1) * CGFloat(i)
            if flipped {
                distance *= -1
            }
            
            line.setAffineTransform(CGAffineTransformMakeRotation(distance))
            
            layer.addSublayer(line)
            lines.append(line)
        }
    }
    
    override func drawRect(rect: CGRect) {
        
        if lines.count == 0 {
            return
        }
        
        for i in 0...lineCount {
            let incomplete: Float = 1.0 - progress
            let line = lines[i]
            if (Float(i) >= Float(incomplete) * Float(lineCount)) {
                line.strokeColor = completeColor!.CGColor
            } else {
                line.strokeColor = incompleteColor!.CGColor
            }
            
        }
    }

}
