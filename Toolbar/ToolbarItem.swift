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
        case flexible
        case fixed
    }
    
    public static let contentInset: UIEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    
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
    
    private(set) var spacing: Spacing?
    
    public var minimumHeight: CGFloat = 44 {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    
    public var minimumWidth: CGFloat = 44 {
        didSet {
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
    
    public convenience init(image: UIImage?, target: Any?, action: Selector?) {
        self.init(frame: .zero)
        self.target = target as AnyObject
        self.action = action
        
        let view: UIImageView = UIImageView(image: image)
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = image
        
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
        self.backgroundColor = .blue
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
        
        self.heightConstraint?.isActive = true
        self.widthConstraint?.isActive = true
        
        super.updateConstraints()
    }
    
    private(set) lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self.target, action: self.action)
        return recognizer
    }()
    
//    private(set) lazy var titleLabelCenterXConstraint: NSLayoutConstraint? = {
//        return self.titleLabel?.centerXAnchor.constraint(equalTo: self.centerXAnchor)
//    }()
//    
//    private(set) lazy var titleLabelCenterYConstraint: NSLayoutConstraint? = {
//        return self.titleLabel?.centerYAnchor.constraint(equalTo: self.centerYAnchor)
//    }()
//    
//    private(set) lazy var titleLabelLeadingConstraint: NSLayoutConstraint? = {
//        return self.titleLabel?.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor)
//    }()
//    
//    private(set) lazy var titleLabelTrailingConstraint: NSLayoutConstraint? = {
//        return self.titleLabel?.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor)
//    }()
//    
//    private(set) lazy var titleLabelWidthConstraint: NSLayoutConstraint? = {
//        return self.titleLabel?.widthAnchor.constraint(equalToConstant: 0)
//    }()
//    
//    private(set) lazy var titleLabelHeightConstraint: NSLayoutConstraint? = {
//        return self.titleLabel?.heightAnchor.constraint(equalToConstant: 0)
//    }()
    
    private(set) lazy var widthConstraint: NSLayoutConstraint? = {
        return self.widthAnchor.constraint(greaterThanOrEqualToConstant: self.minimumWidth)
    }()
    
    private(set) lazy var heightConstraint: NSLayoutConstraint? = {
        return self.heightAnchor.constraint(greaterThanOrEqualToConstant: self.minimumHeight)
    }()
    
    public override var isHidden: Bool {
        willSet {
            self.titleLabel?.isHidden = true
            self.imageView?.isHidden = true
            self.heightConstraint?.isActive = false
            self.widthConstraint?.isActive = false
        }
    }
    
}
