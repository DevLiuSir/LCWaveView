//
//  LCWaveView.swift
//  LCWaveViewExample
//
//  Created by Liu Chuan on 2017/3/15.
//  Copyright © 2017年 LC. All rights reserved.
//


import UIKit


/// 波浪视图
class LCWaveView: UIView {

    /// 波动频率
    public var waveFrequency: CGFloat = 1.5
   
    /// 波动速度
    public var waveSpeed: CGFloat = 0.6
    
    /// 波动高度
    public var waveHeight: CGFloat = 5
    
    /// 波动视图之上的视图(头像)
    public var overView: UIView?
    
    /// 真实波动图层
    fileprivate var realWaveLayer: CAShapeLayer = CAShapeLayer()
   
    /// 蒙版波动图层
    fileprivate var maskWaveLayer: CAShapeLayer = CAShapeLayer()
    
    /// 时间
    fileprivate var timer: CADisplayLink?
    
    /// 边距
    fileprivate var offset: CGFloat = 0
    
    /// 频率
    fileprivate var priFrequency: CGFloat = 0
    
    /// 速度
    fileprivate var priWaveSpeed: CGFloat = 0
    
    /// 高度
    fileprivate var priWaveHeight: CGFloat = 0
    
    /// 开始
    fileprivate var isStarting: Bool = false

    /// 停止
    fileprivate var isStopping: Bool = false
    
    /// 真实波动图层颜色
    public var realWaveColor: UIColor = UIColor.white {
        didSet {
            realWaveLayer.fillColor = realWaveColor.cgColor
        }
    }
    /// 蒙版波动图层颜色
    public var maskWaveColor: UIColor = UIColor.orange {
        didSet {
            maskWaveLayer.fillColor = maskWaveColor.cgColor
        }
    }
   
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        var f = self.bounds
        f.origin.y = frame.size.height
        f.size.height = 0
        maskWaveLayer.frame = f
        realWaveLayer.frame = f
        self.backgroundColor = .clear
        self.layer.addSublayer(realWaveLayer)
        self.layer.addSublayer(maskWaveLayer)
        
    }
    // MARK: - 便利构造器
    convenience init(frame: CGRect, color: UIColor) {
        self.init(frame: frame)
        realWaveColor = color
        maskWaveColor = color.withAlphaComponent(0.7)
        realWaveLayer.fillColor = realWaveColor.cgColor
        maskWaveLayer.fillColor = maskWaveColor.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Method
extension LCWaveView {
    
    /// 添加波动视图之上的视图(头像)
    public func addOverView(oView: UIView) {
        overView = oView
        overView?.center = self.center
        overView?.frame.origin.y = self.frame.height - (overView?.frame.height)!
        self.addSubview(overView!)
    }
    
    /// 开始波动
    public func startWave() {
        if !isStarting {
            removeTimer()
            isStarting = true
            isStopping = false
            priWaveHeight = 0
            priFrequency = 0
            priWaveSpeed = 0
            timer = CADisplayLink(target: self, selector: #selector(waveEvent))
            timer?.add(to: .current, forMode: .commonModes)
        }
    }
    
    /// 停止波动
    public func stopWave() {
        if !isStopping {
            isStarting = false
            isStopping = true
        }
    }
    
    /// 移除定时器
    private func removeTimer() {
        guard timer != nil else {return}
        timer?.invalidate() // 从运行循环中移除定时器
        timer = nil
    }
    
    
    /// 开始波动起来
    private func BeganToWave () {
        guard priWaveHeight < waveHeight else {
            isStarting = false
            return
        }
        priWaveHeight = priWaveHeight + waveHeight / 100
      
        // 1.用一个临时变量,保存当前视图的尺寸
        var f = self.bounds
        
        // 2.给这个变量赋值
        f.origin.y = f.size.height - priWaveHeight
        f.size.height = priWaveHeight
        
        // 3.修改frame的值
        maskWaveLayer.frame = f
        realWaveLayer.frame = f
        priFrequency = priFrequency + waveFrequency / 100
        priWaveSpeed = priWaveSpeed + waveSpeed / 100
    }
    
    /// 结束波动
    private func endToWave () {
        guard priWaveHeight > 0 else {  // 停止
            isStopping = false
            stopWave()
            return
        }
        priWaveHeight = priWaveHeight - waveHeight / 50.0
        
        // 1.用一个临时变量,保存当前视图的尺寸
        var f = self.bounds
        
        // 2.给这个变量赋值
        f.origin.y = f.size.height
        f.size.height = priWaveHeight
        
        // 3.修改frame的值
        maskWaveLayer.frame = f
        realWaveLayer.frame = f
        priFrequency = priFrequency - waveFrequency / 50.0
        priWaveSpeed = priWaveSpeed - waveSpeed / 50.0
    }
    
    /// 其他情况
    private func other() {
        
        offset += priWaveSpeed
        var y: CGFloat = 0.0
        let width: CGFloat = frame.width
        let height: CGFloat = priWaveHeight
        
        // 创建路径1,2
        let path = CGMutablePath()
        let maskPath = CGMutablePath()
        
        // 开始指定一个新的子路径。
        path.move(to: CGPoint(x: 0, y: height))
        maskPath.move(to: CGPoint(x: 0, y: height))
        
        let offset_f = Float(offset * 0.045)
        
        let waveFrequency_f = Float(0.01 * priFrequency)
        
        for x in 0...Int(width) {
            y = height * CGFloat(sinf(waveFrequency_f * Float(x) + offset_f))
            // 把这些点用先的形式绘制路径
            path.addLine(to: CGPoint(x: CGFloat(x), y: y))
            maskPath.addLine(to: CGPoint(x: CGFloat(x), y: -y))
        }
        
        guard overView != nil else {
            // 1.从当前点到指定点, 用线的形式绘制路径
            path.addLine(to: CGPoint(x: width, y: height))
            path.addLine(to: CGPoint(x: 0, y: height))
            maskPath.addLine(to: CGPoint(x: width, y: height))
            maskPath.addLine(to: CGPoint(x: 0, y: height))
            // 2.关闭路径
            maskPath.closeSubpath()
            path.closeSubpath()
            // 3.赋值路径
            realWaveLayer.path = path
            maskWaveLayer.path = maskPath
            return
        }
        let centX = self.bounds.size.width / 2
        let centY = height * CGFloat(sinf(waveFrequency_f * Float(centX) + offset_f))
        let center = CGPoint(x: centX , y: centY + self.bounds.size.height - overView!.bounds.size.height/2 - priWaveHeight - 1 )
        overView?.center = center
    }
    
    /// 浮动事件
    @objc func waveEvent() {
        if isStarting {
            BeganToWave()
        }
        if isStopping {
            endToWave()
        }
        other()
    }
}
