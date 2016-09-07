import Foundation


public struct DConstraint {
    
    // vfs 로 안되는 부분은 NSLayoutConstraint 를 직접 사용해야함 (center 정렬이 vfs 로 안됨)
    public static func centerH(view: UIView, superview: UIView) -> NSLayoutConstraint {
        view.translatesAutoresizingMaskIntoConstraints = false
        let const = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        return const
    }
    
    public static func centerV(view: UIView, superview: UIView) -> NSLayoutConstraint {
        view.translatesAutoresizingMaskIntoConstraints = false
        let const = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        return const
    }

    public static func width(view: UIView, width: CGFloat) -> NSLayoutConstraint {
        let const = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: width)
        return const
    }
    
    public static func height(view: UIView, height: CGFloat) -> NSLayoutConstraint {
        let const = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: height)
        return const
    }
}

public struct DConstraintsBuilder {
    private var views: [String: AnyObject] = [:]
    private var metrics: [String: AnyObject] = [:]
    private(set) public var constraints: [NSLayoutConstraint] = []
    
    public init() {
    }
    
    public init(view: UIView, name: String) {
        view.translatesAutoresizingMaskIntoConstraints = false
        views[name] = view
    }
    
    public func addView(view: AnyObject, name: String) -> DConstraintsBuilder {
        if let view = view as? UIView {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        var const = self
        const.views[name] = view
        return const
    }
    
    // translatesAutoresizingMaskIntoConstraints 변경없이 VFS에서 viewname 만 필요한 경우가 있음
    public func addOnlyViewName(view: AnyObject, name: String) -> DConstraintsBuilder {
        var const = self
        const.views[name] = view
        return const
    }
    
    public func addMetricValue(value: AnyObject, name: String) -> DConstraintsBuilder {
        var const = self
        const.metrics[name] = value
        return const
    }
    
    public func addVFS(vfs: String, options: NSLayoutFormatOptions) -> DConstraintsBuilder {
        var const = self
        let c = NSLayoutConstraint.constraintsWithVisualFormat(vfs, options: options, metrics: metrics, views: views)
        const.constraints = const.constraints + c
        return const
    }
    
    public func addVFS(vfsArray: String...) -> DConstraintsBuilder {
        var const = self
        for vfs in vfsArray {
            const = const.addVFS(vfs, options: NSLayoutFormatOptions(rawValue: 0))
        }
        return const
    }
}