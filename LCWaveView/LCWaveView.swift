//
//  LCWaveView.swift
//  LCWaveViewExample
//
//  Created by Liu Chuan on 2017/3/15.
//  Copyright © 2017年 LC. All rights reserved.
//


import UIKit

// 波浪曲线动画视图
// 波浪曲线公式：y = h * sin(a * x + b);
//      h: 波浪高度， a: 波浪宽度系数， b： 波动的偏移量

/// 波浪视图
class LCWaveView: UIView {
    
    // MARK: - 公开属性

    /// 波浪宽度系数 -> a
    public var waveRate: CGFloat = 1.5
    
    /// 波动速度(默认值:0.5 取值 0 ～ 1)
    public var waveSpeed: CGFloat = 0.5
    
    /// 波动的高度 -> h (默认值: 5)
    public var waveHeight: CGFloat = 5
    
    /// 真实波动图层颜色
    public var realWaveColor: UIColor = UIColor.white {
        didSet {
            realWaveLayer.fillColor = realWaveColor.cgColor
        }
    }
    /// 蒙版波动图层颜色
    public var maskWaveColor: UIColor = UIColor.white {
        didSet {
            maskWaveLayer.fillColor = maskWaveColor.cgColor
        }
    }
    
    /// 波动完成回调
    public var completion: ((_ centerY: CGFloat)->())?
    
    
    // MARK: - 私有属性
    
    /// 真实波动图层
    private lazy var realWaveLayer: CAShapeLayer = CAShapeLayer()
   
    /// 蒙版波动图层
    private lazy var maskWaveLayer: CAShapeLayer = CAShapeLayer()
    
    /// 屏幕刷新率定时器
    private var waveDisplayLink: CADisplayLink?
    
    /// 波浪的偏移量 -> b
    private var offset: CGFloat = 0
    
    /// 频率
    private var priFrequency: CGFloat = 0

    /// 速度
    private var priWaveSpeed: CGFloat = 0

    /// 高度
    private var priWaveHeight: CGFloat = 0
    
    /// 定义变量记录波动视图的状态 -开始（默认为:false）
    private var isStarting: Bool = false

    /// 定义变量记录波动视图的状态 -停止（默认为:false)
    private var isStopping: Bool = false
    
   
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var tempf = bounds
        tempf.origin.y = frame.size.height
        tempf.size.height = 0
        
        maskWaveLayer.frame = tempf
        realWaveLayer.frame = tempf
        
        backgroundColor = .clear
        layer.addSublayer(realWaveLayer)
        layer.addSublayer(maskWaveLayer)
    }
    
    // MARK: - 便利构造器
    
    /// 初始化波浪视图的尺寸位置,以及颜色
    ///
    /// - Parameters:
    ///   - frame: 尺寸位置
    ///   - color: 颜色
    convenience init(frame: CGRect, color: UIColor) {
        self.init(frame: frame)
        
        realWaveColor = color
        maskWaveColor = color.withAlphaComponent(0.7)
        realWaveLayer.fillColor = realWaveColor.cgColor     // 图层的填充颜色
        maskWaveLayer.fillColor = maskWaveColor.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Method
extension LCWaveView {
    
    /// 开始波动
    public func startWave() {
        
        if !isStarting {
            
            removeTimer()   // 先移除屏幕刷新率定时器
            isStarting = true
            isStopping = false
            
    /*   CADisplayLink:一个和屏幕刷新率相同的定时器，需要以特定的模式注册到runloop中，每次屏幕刷新时，会调用绑定的target上的selector这个方法。
         duration:每帧之间的时间
         pause:暂停，设置true为暂停，false为继续
         结束时，需要调用invalidate方法，并且从runloop中删除之前绑定的target跟selector。
         不能被继承
     */
            // 开启定时器
            waveDisplayLink = CADisplayLink(target: self, selector: #selector(waveEvent))
            waveDisplayLink?.add(to: .current, forMode: RunLoop.Mode.common)
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
        // 从运行循环中移除定时器
        waveDisplayLink?.invalidate()
        waveDisplayLink = nil
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


// MARK: - 浮动的三种状态（开始、结束、其他）
extension LCWaveView {
    
    /// 开始波动起来
    private func BeganToWave() {
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
        priFrequency = priFrequency + waveRate / 100
        priWaveSpeed = priWaveSpeed + waveSpeed / 100
    }
    
    /// 结束波动
    private func endToWave() {
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
        priFrequency = priFrequency - waveRate / 50.0
        priWaveSpeed = priWaveSpeed - waveSpeed / 50.0
    }
    
    /// 其他情况
    private func other() {
        
        // 波浪移动的关键：按照指定的速度偏移
        offset += priWaveSpeed
        
        var y: CGFloat = 0.0
        let width: CGFloat = frame.width
        let height: CGFloat = priWaveHeight
        
        // 创建可变图形路径1、2
        let realPath = CGMutablePath()
        let maskPath = CGMutablePath()
        
        // 开始指定一个新的子路径。
        realPath.move(to: CGPoint(x: 0, y: height))
        maskPath.move(to: CGPoint(x: 0, y: height))
        
        let offset_f = Float(offset * 0.045)
        
        let waveFrequency_f = Float(0.01 * priFrequency)
        
        for x in 0...Int(width) {
            
            // 波浪曲线
            y = height * CGFloat(sin(waveFrequency_f * Float(x) + offset_f))
            
            // 把这些点用先的形式绘制路径
            realPath.addLine(to: CGPoint(x: CGFloat(x), y: y))
            maskPath.addLine(to: CGPoint(x: CGFloat(x), y: -y))
        }
        
        let midX = bounds.size.width * 0.5
        let midY = height * sin(midX * CGFloat(waveFrequency_f) + CGFloat(offset_f))
        
        if let callback = completion {
            callback(midY)
        }
        
        // 1.从当前点到指定点, 用线的形式绘制路径
        realPath.addLine(to: CGPoint(x: width, y: height))
        realPath.addLine(to: CGPoint(x: 0, y: height))
        maskPath.addLine(to: CGPoint(x: width, y: height))
        maskPath.addLine(to: CGPoint(x: 0, y: height))
        // 2.关闭路径
        maskPath.closeSubpath()
        realPath.closeSubpath()
        // 3.赋值路径
        realWaveLayer.path = realPath
        maskWaveLayer.path = maskPath
    }
    
}

