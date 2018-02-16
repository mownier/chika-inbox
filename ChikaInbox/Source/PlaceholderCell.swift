//
//  PlaceholderCell.swift
//  ChikaInbox
//
//  Created by Mounir Ybanez on 2/16/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import UIKit

class PlaceholderCell: UITableViewCell {

    var maskLayer: CAShapeLayer!
    var fillLayer: CALayer!
    var animatedLayer: CALayer!
    
    override init(style: UITableViewCellStyle, reuseIdentifier id: String?) {
        super.init(style: style, reuseIdentifier: id)
        self.initSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initSetup()
    }
    
    override func layoutSubviews() {
        var rect = bounds
        
        animatedLayer.frame = rect
        
        fillLayer.frame = rect
        fillLayer.backgroundColor = backgroundColor?.cgColor
        
        let spacing: CGFloat = 8
        let finalPath = UIBezierPath(rect: bounds)
        
        rect.origin.x = spacing
        rect.origin.y = rect.minX
        rect.size.width = 64
        rect.size.height = rect.width
        let avatarPath = UIBezierPath(ovalIn: rect)
        
        rect.origin.x = rect.maxX + spacing
        rect.origin.y += spacing
        rect.size.width = bounds.width - rect.minX - spacing
        rect.size.height = 16
        let titlePath = UIBezierPath(rect: rect)
        
        rect.origin.y = rect.maxY + spacing
        rect.size.height = 12
        let messagePath = UIBezierPath(rect: rect)
        
        rect.origin.y = rect.maxY + spacing
        rect.size.height = 8
        let timePath = UIBezierPath(rect: rect)
        
        finalPath.append(avatarPath)
        finalPath.append(titlePath)
        finalPath.append(messagePath)
        finalPath.append(timePath)
        
        maskLayer.path = finalPath.cgPath
        fillLayer.mask = maskLayer
    }
    
    func initSetup() {
        selectionStyle = .none
        
        maskLayer = CAShapeLayer()
        maskLayer.fillRule = kCAFillRuleEvenOdd
        
        fillLayer = CALayer()
        fillLayer.backgroundColor = UIColor.black.cgColor
        
        animatedLayer = createAnimatedLayer()
        
        layer.addSublayer(animatedLayer)
        layer.addSublayer(fillLayer)
    }
    
    func createAnimatedLayer() -> CALayer {
        let gradientWidth: CGFloat = 0.17
        let gradientFirstStop: CGFloat = 0.1
        let loaderDuration: TimeInterval = 0.85
        
        let gradient = CAGradientLayer()
        gradient.masksToBounds = true
        gradient.colors = [
            UIColor(red: (246.0/255.0), green: (247.0/255.0), blue: (248.0/255.0), alpha: 1).cgColor,
            UIColor(red: (238.0/255.0), green: (238.0/255.0), blue: (238.0/255.0), alpha: 1.0).cgColor,
            UIColor(red: (221.0/255.0), green: (221.0/255.0), blue:(221.0/255.0) , alpha: 1.0).cgColor,
            UIColor(red: (238.0/255.0), green: (238.0/255.0), blue: (238.0/255.0), alpha: 1.0).cgColor,
            UIColor(red: (246.0/255.0), green: (247.0/255.0), blue: (248.0/255.0), alpha: 1).cgColor,
        ]
        gradient.startPoint = CGPoint(x: -1.0 + gradientWidth, y: 0)
        gradient.endPoint = CGPoint(x: 1.0 + gradientWidth, y: 0)
        
        let fromValue = [
            gradient.startPoint.x,
            gradient.startPoint.x,
            0,
            gradientWidth,
            gradientWidth + 1,
            ].map({ Double($0) }).map({ NSNumber(value: $0) })
        
        let toValue = [
            0,
            1,
            1,
            1 + (gradientWidth - gradientFirstStop),
            1 + gradientWidth,
            ].map({ Double($0) }).map({ NSNumber(value: $0) })
        
        gradient.locations = fromValue
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.fromValue = fromValue
        gradientChangeAnimation.toValue = toValue
        gradientChangeAnimation.repeatCount = Float(CGFloat.infinity)
        gradientChangeAnimation.fillMode = kCAFillModeForwards
        gradientChangeAnimation.isRemovedOnCompletion = false
        gradientChangeAnimation.duration = loaderDuration
        gradientChangeAnimation.autoreverses = true
        gradient.add(gradientChangeAnimation, forKey: "locations")
        
        return gradient
    }
    
}
