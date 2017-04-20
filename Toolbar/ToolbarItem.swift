//
//  ToolbarItem.swift
//  Toolbar
//
//  Created by 1amageek on 2017/04/20.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import UIKit

public class ToolbarItem: UIView {
    
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
    
    public var minimumHeight: CGFloat = 44
    
    public var minimumWidth: CGFloat = 44
    
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
        
        let view: UIImageView = UIImageView(frame: frame)
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
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .blue
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func updateConstraints() {
        
        self.titleLabel?.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.titleLabel?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.titleLabel?.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor).isActive = true
        self.titleLabel?.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true
        
        self.heightAnchor.constraint(greaterThanOrEqualToConstant: self.minimumHeight).isActive = true
        self.widthAnchor.constraint(greaterThanOrEqualToConstant: self.minimumWidth).isActive = true
        super.updateConstraints()
    }
    
    private(set) lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self.target, action: self.action)
        return recognizer
    }()

    public override var isHidden: Bool {
        willSet {
            self.constraints.forEach { (constraint) in
                constraint.isActive = !newValue
            }
            self.titleLabel?.constraints.forEach({ (constraint) in
                constraint.isActive = !newValue
            })
        }
    }
    
}
