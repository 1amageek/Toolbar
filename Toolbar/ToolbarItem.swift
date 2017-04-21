//
//  ToolbarItem.swift
//  Toolbar
//
//  Created by 1amageek on 2017/04/20.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import UIKit

public class ToolbarItem: UIView {
    
    public enum Spacing {
        case none
        case flexible
        case fixed
    }
    
    public var title: String? {
        didSet {
            self.titleLabel?.text = title
            self.setNeedsUpdateConstraints()
        }        
    }
    
    public var image: UIImage? {
        didSet {
            self.imageView?.image = image
            self.imageView?.setNeedsDisplay()
        }
    }
    
    private(set) var titleLabel: UILabel?
    
    private(set) var imageView: UIImageView?
    
    private(set) var customView: UIView?
    
    private(set) var spacing: Spacing = .none
    
    public override var isHidden: Bool {
        didSet {
            self.titleLabel?.isHidden = isHidden
            self.imageView?.isHidden = isHidden
            self.minimumWidthConstraint?.isActive = !isHidden
            self.minimumHeightConstraint?.isActive = !isHidden
        }
    }
    
    public var isHighlighted: Bool = false {
        didSet {
            self.setHighlighted(isHighlighted, animated: true)
        }
    }
    
    public var contentInset: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    public var minimumHeight: CGFloat {
        return Toolbar.defaultHeight
    }
    
    public var fixedWidth: CGFloat = 20
    
    public var minimumWidth: CGFloat {
        if let label: UILabel = self.titleLabel {
            let size: CGSize = label.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
            return self.contentInset.left + size.width + self.contentInset.right
        }
        
        if let view: UIImageView = self.imageView {
            let size: CGSize = view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
            return self.contentInset.left + size.width + self.contentInset.right
        }
        return self.fixedWidth
    }
    
    public var maximumHeight: CGFloat = UIScreen.main.bounds.height {
        didSet {
            if maximumHeight < minimumHeight {
                debugPrint("[ToolbarItem] *** error: maximumHeight can not be smaller than minimumHeight")
            }
            setNeedsUpdateConstraints()
        }
    }
    
    public var maximumWidth: CGFloat = UIScreen.main.bounds.width {
        didSet {
            if maximumWidth < minimumWidth {
                debugPrint("[ToolbarItem] *** error: maximumWidth can not be smaller than minimumWidth")
            }
            setNeedsUpdateConstraints()
        }
    }
    
    public weak var target: AnyObject?
    
    public var action: Selector?

    public convenience init(title: String?, target: Any?, action: Selector?) {
        self.init(frame: .zero)
        self.target = target as AnyObject
        self.action = action
        
        let label: UILabel = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = title
        
        self.title = title
        self.titleLabel = label
        
        self.addSubview(label)
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    public convenience init(image: UIImage, target: Any?, action: Selector?) {
        self.init(frame: .zero)
        self.target = target as AnyObject
        self.action = action
        
        let view: UIImageView = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.image = image
        self.imageView = view
        
        self.addSubview(view)
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    public convenience init(customView: UIView) {
        self.init(frame: .zero)
        self.addSubview(customView)
        customView.translatesAutoresizingMaskIntoConstraints = false
        self.customView = customView
    }
    
    public convenience init(spacing: Spacing) {
        self.init(frame: .zero)
        self.spacing = spacing
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isOpaque = false
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func updateConstraints() {
        
        if let label: UILabel = self.titleLabel {
            let size: CGSize = label.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            label.widthAnchor.constraint(equalToConstant: size.width).isActive = true
            label.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
        
        if let view: UIImageView = self.imageView {
            view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            view.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            view.widthAnchor.constraint(equalToConstant: view.bounds.width).isActive = true
            view.heightAnchor.constraint(equalToConstant: view.bounds.height).isActive = true
        }
        
        if let view: UIView = self.customView {
            view.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true
            view.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
        }
        
        self.minimumWidthConstraint?.isActive = true
        self.minimumHeightConstraint?.isActive = true
        self.maximumWidthConstraint?.isActive = true
        self.maximumHeightConstraint?.isActive = true
        super.updateConstraints()
    }
    
    // MARK: -
    
    // override function
    public func setHighlighted(_ highlighted: Bool, animated: Bool) {
        // default function
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = highlighted ? 0.5 : 1
            })
        } else {
            self.alpha = highlighted ? 0.5 : 1
        }
    }
    
    // MARK: -
    
    private(set) lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self.target, action: self.action)
        return recognizer
    }()
    
    private(set) lazy var minimumWidthConstraint: NSLayoutConstraint? = {
        return self.widthAnchor.constraint(greaterThanOrEqualToConstant: self.minimumWidth)
    }()
    
    private(set) lazy var minimumHeightConstraint: NSLayoutConstraint? = {
        return self.heightAnchor.constraint(greaterThanOrEqualToConstant: self.minimumHeight)
    }()
    
    private(set) lazy var maximumWidthConstraint: NSLayoutConstraint? = {
        return self.widthAnchor.constraint(lessThanOrEqualToConstant: self.maximumWidth)
    }()
    
    private(set) lazy var maximumHeightConstraint: NSLayoutConstraint? = {
        return self.heightAnchor.constraint(lessThanOrEqualToConstant: self.maximumHeight)
    }()
    
    // MARK: - Touches
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.isHighlighted = true
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.isHighlighted = false
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.isHighlighted = false
    }
    
}
