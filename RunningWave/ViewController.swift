//
//  ViewController.swift
//  RunningWave
//
//  Created by Admin on 06/02/2019.
//  Copyright © 2019 aadudyrev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let touch = touches.first
        if let point = touch?.location(in: self.view) {
            showWave(fromPoint: point, inView: self.view)
        }
    }
}

extension UIViewController {
    
    func showWave(fromPoint: CGPoint, inView: UIView) {
        var conf = RunningWave.Configuration()
        conf.centerPoint = fromPoint
        conf.superlayer = inView.layer
        let waveMaster = RunningWave(with: conf)
        waveMaster.animate()
    }
    
}
