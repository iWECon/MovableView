import UIKit

open class MovableView: UIView {
    
    public enum HorizontallyPosition {
        /// center.x is to the left of the center point
        case left
        /// center.x is to the right of the center point
        case right
    }
    
    public enum VerticallyPosition {
        /// center.y is to the top of the center point
        case top
        /// center.y is to the bottom of the center point
        case bottom
    }
    
    private var _isMoving = false
    private var _offsetPoint: CGPoint = .zero
    
    public private(set) var horizontallyPosition: HorizontallyPosition = .left {
        willSet {
            guard horizontallyPosition != newValue else { return }
            horizontallyPositionChange(newValue)
        }
    }
    public private(set) var verticallyPosition: VerticallyPosition = .top {
        willSet {
            guard verticallyPosition != newValue else { return }
            verticallyPositionChange(newValue)
        }
    }
    
    /// can exceed the parent view
    /// the view does not automatically adjust point if true
    open var isExceedParentView = false
    
    open var isEdgeAdsorption = true
    open var safeEdge: UIEdgeInsets = .zero
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard _isMoving == false else { return }
        _isMoving = true
        
        let startPoint = touches.first?.location(in: self.superview) ?? .zero
        _offsetPoint = .init(x: startPoint.x - self.center.x, y: startPoint.y - self.center.y)
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard _isMoving,
              let spv = superview,
              let touchPoint = touches.first?.location(in: spv)
        else { return }
        
        let x = touchPoint.x - _offsetPoint.x
        let y = touchPoint.y - _offsetPoint.y
        self.center = .init(x: x, y: y)
        
        if center.x > spv.center.x {
            horizontallyPosition = .right
        } else if center.x < spv.center.x {
            horizontallyPosition = .left
        }
        
        if center.y > spv.center.y {
            verticallyPosition = .bottom
        } else if center.y < spv.center.y {
            verticallyPosition = .top
        }
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        _isMoving = false
        _endMove()
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        _isMoving = false
        _endMove()
    }
    
    private func _endMove() {
        if isExceedParentView {
            return
        }
        
        guard let spv = superview else { return }
        
        var newPoint: CGPoint = .zero
        if horizontallyPosition == .right {
            if (frame.maxX + safeEdge.right) > spv.frame.width || isEdgeAdsorption {
                newPoint.x = spv.frame.width - self.frame.width - safeEdge.right
            } else {
                newPoint.x = frame.origin.x
            }
        } else if horizontallyPosition == .left {
            if frame.minX < safeEdge.left || isEdgeAdsorption {
                newPoint.x = safeEdge.left
            } else {
                newPoint.x = frame.origin.x
            }
        }
        
        if verticallyPosition == .bottom {
            if (frame.maxY + safeEdge.bottom) > spv.frame.height {
                newPoint.y = spv.frame.height - self.frame.height - safeEdge.bottom
            } else {
                newPoint.y = frame.origin.y
            }
        } else if verticallyPosition == .top {
            if frame.minY < safeEdge.top {
                newPoint.y = safeEdge.top
            } else {
                newPoint.y = frame.origin.y
            }
        }
        
        // move to safe area
        UIView.animate(withDuration: 0.23) {
            self.frame.origin = newPoint
        }
    }
    
    open func horizontallyPositionChange(_ position: HorizontallyPosition) { }
    
    open func verticallyPositionChange(_ position: VerticallyPosition) { }
}
