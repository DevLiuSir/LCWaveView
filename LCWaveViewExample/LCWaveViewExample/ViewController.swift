//
//  ViewController.swift
//  LCWaveViewExample
//
//  Created by Liu Chuan on 2018/2/23.
//  Copyright © 2018年 LC. All rights reserved.
//

import UIKit

/// 屏幕的宽度
private let screenW = UIScreen.main.bounds.width

/// 头像视图的宽度
private let iconImageWidth: CGFloat = 100

/// 波动视图的高度
private let waveViewHeight: CGFloat = 200

/// 单元格重用标识符
private let identifier = "cellID"



class ViewController: UIViewController {
    
    /// 表格
    @IBOutlet weak var table: UITableView!
    
    // MARK: - Lazy Loading
    
    /** LCWaveView **/
    private lazy var waveView: LCWaveView = {
        let waveView = LCWaveView(frame: CGRect(x: 0, y: 0, width: screenW, height: waveViewHeight), color: .white)
        waveView.waveRate = 2
        waveView.waveSpeed = 1
        waveView.waveHeight = 7
        return waveView
    }()
    
    /// 头像视图
    private lazy var iconImageView: UIImageView = {
        let image = UIImageView(frame: CGRect(x: screenW / 2 - iconImageWidth / 2, y: 0, width: iconImageWidth, height: iconImageWidth))
        image.layer.borderColor  = UIColor.white.cgColor
        image.layer.cornerRadius = image.bounds.width / 2
        image.layer.masksToBounds = true
        image.layer.borderWidth = 3
        image.layer.contents = UIImage(named: "UserAvatar.png")?.cgImage
        return image
    }()
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
    }
}

// MARK: - Custom Method
extension ViewController {
    
    /// 配置UI界面
    private func configUI() {
        configTableView()
        configWaveView()
    }
    
    /// 配置波动视图
    private func configWaveView() {
        waveView.completion = { centerY in  // 波浪动画回调
            // 同步更新头像视图的y坐标
            self.iconImageView.frame.origin.y = waveViewHeight + centerY - iconImageWidth
        }
        waveView.addSubview(iconImageView)
        waveView.startWave()
    }
    
    /// 配置表格
    private func configTableView() {
        table.backgroundColor = .red
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        table.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
        table.tableHeaderView = waveView
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}
