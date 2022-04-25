//
//  GradientBorderedLabelView.swift
//  SwiftGenTest
//
//  Created by Push on 2022/4/9.
//

import Foundation
import UIKit

public class GradientBorderedLabelView: UIView {

    public var text: String? {
        
        didSet {
            textLayer.string = text
            setNeedsLayout()
        }
    }
    
    /// 字体
    public var font: UIFont? {
        get{
            return self.font
        }
        set{
            if let fontName = newValue?.fontName, let fontSize = newValue?.pointSize
            {
                textLayer.font = CTFontCreateWithName(fontName as CFString, fontSize, nil)
                textLayer.fontSize = fontSize
            }
        }
    }
    
    /// 最大宽度
    public var preferredMaxLayoutWidth: CGFloat = .greatestFiniteMagnitude

    /// 文字颜色
    public var textColors: [CGColor]? {
        get{ return self.textColors}
        set{
            gradientLayer.colors = newValue
        }
    }
    /// 截断模式
    public var truncationMode: CATextLayerTruncationMode? {
        get{ return self.truncationMode}
        set{
            textLayer.truncationMode = newValue ?? .end
        }
    }
    
    /// 布局模式
    public var alignmentMode: CATextLayerAlignmentMode? {
        get{ return self.alignmentMode}
        set{
            textLayer.alignmentMode = newValue ?? .left
        }
    }
    
    /// 渐变方向
    public var startPoint: CGPoint?{
        get{ return self.startPoint}
        set{
            gradientLayer.startPoint = newValue ?? CGPoint(x: 1, y: 0)
        }
    }
    
    /// 渐变方向
    public var endPoint: CGPoint?{
        get{ return self.endPoint}
        set{
            gradientLayer.endPoint = newValue ?? CGPoint(x: 1, y: 0)
        }
    }
    
    private var oldFrame: CGRect = .zero

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    private var textLayer = CATextLayer()
    private var gradientLayer = CAGradientLayer()

    public override func layoutSubviews() {
        defer{
            layoutTextLayer()
        }
        if oldFrame == .zero {
            oldFrame = self.frame
        }
        super.layoutSubviews()
    }
    
    
    
    private var resultSize: CGSize = .zero

    override open var intrinsicContentSize: CGSize {
        return resultSize
    }
    
    
    @discardableResult
    private func layoutTextLayer() -> CGSize{
        if let string = textLayer.string as? String {
            let boundingBox = string.boundingRect(with: CGSize(width: max(oldFrame.width, preferredMaxLayoutWidth), height: oldFrame.height), options: [.usesLineFragmentOrigin,.usesFontLeading], attributes: [NSAttributedString.Key.font: textLayer.font as Any], context: nil)
            CATransaction.setDisableActions(true)
            self.textLayer.frame.size = ceilSize(boundingBox.size)
            self.gradientLayer.frame.size = ceilSize(boundingBox.size)
            CATransaction.commit()
            resultSize = ceilSize(CGSize(width: boundingBox.width, height: boundingBox.height))
            invalidateIntrinsicContentSize()
            return resultSize
        }else{
            textLayer.frame.size = .zero
            gradientLayer.frame.size = .zero
            invalidateIntrinsicContentSize()
            return .zero
        }
    }
    
    private func greatestSize(size: CGSize) -> CGSize{
        return CGSize(width: size.width > 0 ? size.width: .greatestFiniteMagnitude, height: size.height > 0 ? size.height: .greatestFiniteMagnitude)
    }
    
    private func ceilSize(_ size: CGSize) -> CGSize{
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }
    
    private func configure(){
        textLayer.string = text
        textLayer.isWrapped = true
        textLayer.truncationMode = .end
        textLayer.contentsScale = UIScreen.main.scale
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.black.cgColor]
        gradientLayer.startPoint = CGPoint(x: 1, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0)
        gradientLayer.mask = textLayer
        layer.addSublayer(gradientLayer)
    }
    
}


