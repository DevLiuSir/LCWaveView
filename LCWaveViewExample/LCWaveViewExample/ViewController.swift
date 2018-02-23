//
//  ViewController.swift
//  LCWaveViewExample
//
//  Created by Liu Chuan on 2018/2/23.
//  Copyright © 2018年 LC. All rights reserved.
//

import UIKit

/// 屏幕宽
private let screenW = UIScreen.main.bounds.width

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // overView
        let overView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        overView.layer.cornerRadius = overView.bounds.height / 2
        overView.layer.masksToBounds = true
        overView.layer.borderColor  = UIColor.white.cgColor
        overView.layer.borderWidth = 3
        overView.layer.contents = UIImage(named: "yourtion")?.cgImage
        
        
        /** LCWaveView **/
        let frame = CGRect(x: 0, y: 0, width: screenW, height: 200)
        let waveView = LCWaveView(frame: frame, color: .white)
        waveView.backgroundColor = .red
        waveView.waveFrequency = 2
        waveView.waveSpeed = 1
        view.addSubview(waveView)
//        waveView.addOverView(oView: overView)
        waveView.startWave()
    }
    
}

