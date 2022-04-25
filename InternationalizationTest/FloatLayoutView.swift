/*
 
 类似于一堆标签的布局
 
 支持左右居中三种模式
 
 */
import UIKit

fileprivate var FloatLayoutViewAutomaticalMaximumItemSize: CGSize = CGSize(width: -1, height: -1)

public class FloatLayoutView: UIView {
    
    /// FloatLayoutView 内部的间距，默认为 UIEdgeInsetsZero
    open var padding: UIEdgeInsets = .zero
    
    /// item 的最小宽高，默认为 CGSizeZero，也即不限制。
    open var minimumItemSize: CGSize = .zero
    
    ///  item 的最大宽高，默认为 FloatLayoutViewAutomaticalMaximumItemSize，也即不超过 floatLayoutView 自身最大内容宽高。
    open var maximumItemSize: CGSize = FloatLayoutViewAutomaticalMaximumItemSize
    
    /// item上下间距
    open var lineSpacing: CGFloat = 0
    
    /// item左右间距
    open var interitemSpacing: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        didInitialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func didInitialize(){
        contentMode = .left
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let size = layoutSubviews(with: size, shouldLayout: false)
        return size
    }
    
    public override func layoutSubviews() {
        defer { layoutSubviews(with: bounds.size, shouldLayout: true) }
        super.layoutSubviews()
    }
    
    @discardableResult
    private func layoutSubviews(with size:CGSize, shouldLayout: Bool) -> CGSize{
        
        let visibleItemViews = visibleSubviews()
        
        if visibleItemViews.count == 0 {
            return CGSize(width: self.padding.left + self.padding.right, height: self.padding.top + self.padding.bottom)
        }
        
        var itemViewOrigin: CGPoint = CGPoint(x: padding.left, y: padding.top)
        
        var currentRowMaxY: CGFloat = itemViewOrigin.y
        let maximumItemSize = __CGSizeEqualToSize(maximumItemSize, FloatLayoutViewAutomaticalMaximumItemSize) ? CGSize(width: size.width - (padding.left + padding.right), height: zeroTogreatestFiniteMagnitude(size.height) - (padding.top + padding.bottom)) : maximumItemSize
        var line: Int = -1
        var currentRowSubviews: [UIView] = []
        var currentRowWidth: CGFloat = 0
        var currentRowMaxHeight: CGFloat = 0

        for (i, itemView) in visibleItemViews.enumerated() {
            var itemViewFrame: CGRect = .zero
            var itemViewSize: CGSize = itemView.sizeThatFits(maximumItemSize)
            
            itemViewSize.width = min(maximumItemSize.width, max(minimumItemSize.width, itemViewSize.width))
            itemViewSize.height = min(maximumItemSize.height, max(minimumItemSize.height, itemViewSize.height))
            let shouldBreakline: Bool = i == 0 ? true : itemViewOrigin.x + interitemSpacing + itemViewSize.width + padding.right > size.width
            
            if shouldBreakline {
                if shouldLayout {
                    updateOrigin(with: currentRowSubviews, superViewSize: size, currentRowWidth: currentRowWidth, currentRowMaxHeight: currentRowMaxHeight)
                }
                currentRowWidth = 0
                currentRowMaxHeight = 0
                currentRowSubviews.removeAll()
                line += 1
                currentRowMaxY += line > 0 ? lineSpacing : 0
                itemViewFrame = CGRect(x: padding.left, y: currentRowMaxY, width: itemViewSize.width, height: itemViewSize.height)
                itemViewOrigin.y = itemViewFrame.minY
            }else{
                itemViewFrame = CGRect(x: itemViewOrigin.x + interitemSpacing, y: itemViewOrigin.y, width: itemViewSize.width, height: itemViewSize.height)
            }
            itemViewOrigin.x = itemViewFrame.maxX + interitemSpacing
            currentRowMaxY = max(currentRowMaxY, itemViewFrame.maxY + lineSpacing)
            if shouldLayout{
                itemView.frame = itemViewFrame
                currentRowSubviews.append(itemView)
                currentRowWidth += itemViewFrame.width + interitemSpacing + interitemSpacing
                currentRowMaxHeight = max(currentRowMaxHeight, itemViewFrame.height)
            }
        }
        
        if shouldLayout {
            updateOrigin(with: currentRowSubviews, superViewSize: size, currentRowWidth: currentRowWidth, currentRowMaxHeight: currentRowMaxHeight)
        }
        
        currentRowMaxY -= lineSpacing
        let resultSize = CGSize(width: size.width, height: currentRowMaxY + padding.bottom)
        self.resultSize = resultSize
        invalidateIntrinsicContentSize()
        return resultSize
    }
    
    private var resultSize: CGSize = .zero
    
    override open var intrinsicContentSize: CGSize {
        return resultSize
    }
    
    private func updateOrigin(with subViews: [UIView], superViewSize: CGSize, currentRowWidth: CGFloat, currentRowMaxHeight: CGFloat){
        subViews.forEach { V in
            switch contentMode {
                case .left:
                    V.frame.origin.x += 0
                case .center:
                    V.frame.origin.x += (superViewSize.width - (currentRowWidth - interitemSpacing - interitemSpacing)) / 2
                case .right:
                    V.frame.origin.x += superViewSize.width - (currentRowWidth - interitemSpacing - interitemSpacing)
                default:
                    V.frame.origin.x += 0
            }
//            if V.frame.origin.y > 0{
                V.frame.origin.y += (currentRowMaxHeight - V.frame.size.height)/2
//            }
        }
    }
    
    private func visibleSubviews() -> [UIView]{
        var visibleItemViews: [UIView] = [];
        for subV in self.subviews {
            if !subV.isHidden {
                visibleItemViews.append(subV)
            }
        }
        return visibleItemViews
    }
    
    private func zeroTogreatestFiniteMagnitude(_ num: CGFloat) -> CGFloat{
        if num <= 0 {
            return CGFloat.greatestFiniteMagnitude
        }
        return num
    }
}
