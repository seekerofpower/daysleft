//
//  CounterView.swift
//  daysleft
//
//  Created by John Pollard on 19/02/2015.
//  Copyright (c) 2015 Brave Location Software. All rights reserved.
//  Based heavily on an article at http://www.raywenderlich.com/90690/modern-core-graphics-with-swift-part-1

import UIKit

let π:CGFloat = CGFloat(M_PI)

@IBDesignable public class CounterView: UIView {
    
    @IBInspectable public var counter: Int = 5
    @IBInspectable public var maximumValue: Int = 8
    @IBInspectable public var arcWidth: CGFloat = 76
    @IBInspectable public var outlineWidth: CGFloat = 5.0
    @IBInspectable public var outlineColor: UIColor = UIColor.blueColor()
    @IBInspectable public var counterColor: UIColor = UIColor.orangeColor()
    
    public func clearControl() {
        // First clear all existing layers
        if let currentlayers = self.layer.sublayers {
            for sublayer in currentlayers {
                sublayer.removeFromSuperlayer()
            }
        }
    }
    
    public func updateControl() {
        self.clearControl()

        let circle: CAShapeLayer = CAShapeLayer(layer: self.layer)
        
        // Define the center point of the view where you’ll rotate the arc around
        let center = CGPoint(x:bounds.width/2, y: bounds.height/2)
        
        // Calculate the radius based on the max dimension of the view
        let radius: CGFloat = max(bounds.width, bounds.height)
        
        // Define the start and end angles for the arc
        let startAngle: CGFloat = 3 * π / 4
        let endAngle: CGFloat = π / 4
        
        // Create a path based on the center point, radius, and angles you just defined
        var path = UIBezierPath(arcCenter: center,
            radius: bounds.width/2 - self.arcWidth/2,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true)

        circle.path = path.CGPath
        circle.fillColor = UIColor.clearColor().CGColor
        circle.strokeColor = self.counterColor.CGColor
        circle.lineWidth = self.arcWidth
        self.layer.addSublayer(circle)
        
        // Now add the progress circle
        let progress: CAShapeLayer = CAShapeLayer(layer: self.layer)
        
        
        // First calculate the difference between the two angles
        // ensuring it is positive
        let angleDifference: CGFloat = 2 * π - startAngle + endAngle
        
        // Then calculate the arc for each single glass
        let arcLengthPerGlass = angleDifference / CGFloat(maximumValue)
        
        // Then multiply out by the actual glasses drunk
        let progressEndAngle = arcLengthPerGlass * CGFloat(counter) + startAngle
        
        var progressPath = UIBezierPath(arcCenter: center,
            radius: bounds.width/2 - self.arcWidth/2,
            startAngle: startAngle,
            endAngle: progressEndAngle,
            clockwise: true)

        progress.path = progressPath.CGPath
        progress.fillColor = UIColor.clearColor().CGColor
        progress.strokeColor = self.outlineColor.CGColor
        progress.lineWidth = self.arcWidth

        self.layer.addSublayer(progress)
        
        // Now animate the progress drawing
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 0.5
        animation.removedOnCompletion = true
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        progress.addAnimation(animation, forKey: "drawProgressAnimation")
    }
}
