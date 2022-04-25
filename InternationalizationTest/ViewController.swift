//
//  ViewController.swift
//  InternationalizationTest
//
//  Created by Push on 2022/2/10.
//

import UIKit
import Photos
//import Common
import SnapKit

class ViewController: UIViewController {

    var langs:[String: String]?    
    let layoutView = FloatLayoutView(frame: .zero)
    let xxxview: UIView = UIView(frame: .zero)
    let gradientLabel = GradientBorderedLabelView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        gradientLabel.text = "Some gradient text from code with custom font 98dhh dhddhdhdhkjskhadsdhasdhlsdkja"
        gradientLabel.font = UIFont.boldSystemFont(ofSize: 20)
        gradientLabel.preferredMaxLayoutWidth = view.frame.width
        gradientLabel.backgroundColor = .red
        view.addSubview(gradientLabel)
        gradientLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
//            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(100)
//            make.width.equalTo(122)
//            make.height.equalTo(300)
        }
        
        return
        
        view.addSubview(self.layoutView)
        layoutView.backgroundColor = .red
        layoutView.contentMode = .center
        layoutView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        view.addSubview(xxxview)
        xxxview.snp.makeConstraints { make in
            make.top.equalTo(layoutView.snp.bottom)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(100)
        }
        
        
        let xxlabel = UILabel()
        xxlabel.text = "1"
        xxlabel.font = UIFont.boldSystemFont(ofSize: 24)
        xxlabel.textColor = .purple
        layoutView.addSubview(xxlabel)
        
        for i in 0...50 {
            
            let label = UILabel()
            label.text = " 第\(i)个Item "

            if i == 0 {
                label.text = " 设置内部的间距 \nrr"
            }
            
            if i == 1 {
                label.text = " 设置Item间距 "
            }
            
            if i == 2 {
                label.text = " 自适应高度 "
            }

            label.numberOfLines = 0
            label.sizeToFit()
            layoutView.addSubview(label)
            label.backgroundColor = .yellow
            label.layer.cornerRadius = 10
            label.layer.masksToBounds = true
        }
        
        xxlabel.text = "FloatLayoutView支持左右居中布局"

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if layoutView.contentMode == .right {
            layoutView.contentMode = .left
            layoutView.lineSpacing = 10
            layoutView.interitemSpacing = 1
        }else if layoutView.contentMode == .left{
            layoutView.contentMode = .center
            layoutView.interitemSpacing = 5
            layoutView.lineSpacing = 1
        }else if layoutView.contentMode == .center{
            layoutView.contentMode = .right
            layoutView.lineSpacing = 5
            layoutView.interitemSpacing = 5
        }
        
        layoutView.setNeedsLayout()
        
        gradientLabel.text = "Some gradient text from code with"

    }
    
    
}

