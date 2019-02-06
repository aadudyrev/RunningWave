//
//  RunningWave.swift
//  RunningWave
//
//  Created by Admin on 06/02/2019.
//  Copyright © 2019 aadudyrev. All rights reserved.
//

import UIKit

class RunningWave: NSObject {
    
    struct Configuration {
        var superlayer: CALayer? = nil
        var centerPoint: CGPoint = CGPoint.zero
        var externalRadius: CGFloat = 40
        var internalToExternalRadiusRelation: CGFloat = 0.8
        
        var donutColors = [UIColor.clear,
                           UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5),
                           UIColor.clear]
        
        var animationScaleFactor: CGFloat = 5.0
        var animationDuration = 0.8
        
        var innerRadius: CGFloat {
            get {
                return externalRadius * internalToExternalRadiusRelation
            }
        }
    }
    
    private let configuration: Configuration
    private weak var rootLayer: CALayer?
    
    required init(with configuration: Configuration) {
        self.configuration = configuration
        
        super.init()
        
        configure()
    }
    
    convenience override init() {
        self.init(with: Configuration())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        let layerFrame = rootFrame(fromCenter: configuration.centerPoint, radius: configuration.externalRadius)
        let rootLayer = getRootLayer(withFrame: layerFrame)
        
        let sublayersFrame = rootLayer.bounds
        let centerPoint = CGPoint(x: sublayersFrame.width / 2, y: sublayersFrame.height / 2)
        let path = getDonutPath(withCenter: centerPoint,
                                externalRadius: configuration.externalRadius,
                                innerRadius: configuration.innerRadius)
        let donutLayer = getDonutLayer(withFrame: sublayersFrame, path: path)
        
        let colorLocations = [NSNumber(value: Double(configuration.internalToExternalRadiusRelation)),
                              NSNumber(value: Double((1 + configuration.internalToExternalRadiusRelation) / 2))]
        let gradientLayer = getGradientLayer(withFrame: donutLayer.bounds,
                                             colors: configuration.donutColors,
                                             locations: colorLocations)
        
        donutLayer.addSublayer(gradientLayer)
        rootLayer.addSublayer(donutLayer)
        configuration.superlayer?.insertSublayer(rootLayer, above: configuration.superlayer?.sublayers?.last)
        
        self.rootLayer = rootLayer
    }
    
    private func rootFrame(fromCenter centerPoint: CGPoint, radius: CGFloat) -> CGRect {
        let origin = CGPoint(x: centerPoint.x - radius, y: centerPoint.y - radius)
        let diameter = radius * 2
        let frame = CGRect(x: origin.x, y: origin.y, width: diameter, height: diameter)
        
        return frame
    }
    
    private func getRootLayer(withFrame frame: CGRect) -> CALayer {
        let rootLayer = CALayer()
        rootLayer.frame = frame
        rootLayer.shouldRasterize = true
        rootLayer.rasterizationScale = UIScreen.main.scale
        
        return rootLayer
    }
    
    private func getDonutLayer(withFrame frame: CGRect, path: UIBezierPath) -> CALayer {
        let donutMask = CAShapeLayer()
        donutMask.frame = frame
        donutMask.fillRule = .evenOdd
        donutMask.path = path.cgPath
        
        let donutLayer = CAShapeLayer()
        donutLayer.mask = donutMask
        donutLayer.frame = frame
        donutLayer.fillRule = .evenOdd
        donutLayer.path = path.cgPath
        donutLayer.masksToBounds = true
        donutLayer.fillColor = UIColor.clear.cgColor
        
        return donutLayer
    }
    
    private func getGradientLayer(withFrame frame: CGRect, colors: [UIColor], locations: [NSNumber]) -> CALayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        gradientLayer.type = .radial
        gradientLayer.colors = colors.map{ $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.locations = locations
        
        return gradientLayer
    }
    
    private func getDonutPath(withCenter centerPoint: CGPoint, externalRadius: CGFloat, innerRadius: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.addArc(withCenter: centerPoint,
                    radius: externalRadius,
                    startAngle: 0,
                    endAngle: CGFloat.pi * 2,
                    clockwise: true)
        path.addArc(withCenter: centerPoint,
                    radius: innerRadius,
                    startAngle: 0,
                    endAngle: CGFloat.pi * 2,
                    clockwise: true)
        
        return path
    }
    
    func animate() {
        guard let rootLayer = self.rootLayer else { return }
        
        let scaleAnimation = animateScale(fromTransform: rootLayer.transform, scaleFactor: configuration.animationScaleFactor)
        let opacityAnimation = animateOpacity(fromOpacity: rootLayer.opacity)
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [scaleAnimation, opacityAnimation]
        groupAnimation.duration = configuration.animationDuration
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = .forwards
        groupAnimation.delegate = self
        
        rootLayer.add(groupAnimation, forKey: "WaveAnimation")
    }
    
    private func animateScale(fromTransform: CATransform3D, scaleFactor: CGFloat) -> CAAnimation {
        var toTransform = CATransform3DIdentity
        toTransform.m34 = -1 / 1000.0
        toTransform = CATransform3DScale(toTransform,
                                         scaleFactor,
                                         scaleFactor,
                                         scaleFactor)
        
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = fromTransform
        animation.toValue = toTransform
        
        return animation
    }
    
    private func animateOpacity(fromOpacity: Float) -> CAAnimation {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = fromOpacity
        animation.toValue = 0.0
        
        return animation
    }
}

extension RunningWave: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.rootLayer?.removeAllAnimations()
        self.rootLayer?.removeFromSuperlayer()
    }
    
}
