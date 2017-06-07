//
//  Toolbar.swift
//  Toolbar
//
//  Created by 1amageek on 2017/04/20.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import UIKit

public class Toolbar: UIView {
    
    public enum LayoutMode {
        case auto
        case munual
    }
    
    public override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    public static let defaultHeight: CGFloat = 44
    
    /** 
     Toolbar layout mode
     When frame is set, it becomes manual mode
     Setting .zero in frame sets it to auto mode
    */
    private(set) var layoutMode: LayoutMode = .auto
    
    /// Maximum value of high value of toolbar
    public var maximumHeight: CGFloat = UIScreen.main.bounds.height
    
    public var minimumHeight: CGFloat = Toolbar.defaultHeight
    
    private(set) var items: [ToolbarItem] = []
    
    // MARK: - Constraint
    
    private var minimumHeightConstraint: NSLayoutConstraint?
    
    private var maximumHeightConstraint: NSLayoutConstraint?
    
    private var leadingConstraint: NSLayoutConstraint?
    
    private var trailingConstraint: NSLayoutConstraint?
    
    // MARK: -
    
    // manual mode layout frame.size.width
    private var widthConstraint: NSLayoutConstraint?
    
    // manual mode layout frame.origin.y
    private var topConstraint: NSLayoutConstraint?
    
    public override var frame: CGRect {
        didSet {
            if frame != .zero {
                self.layoutMode = .munual
            }
            self.setNeedsLayout()
        }
    }
    
    
    // MARK: - Init
    
    /**
     Initialize in autolayout mode.
    */
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        if frame != .zero {
            self.layoutMode = .munual
        }
        
        self.addSubview(backgroundView)
        self.addSubview(stackView)
        self.backgroundColor = .clear
        self.isOpaque = false
        self.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        backgroundView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func updateConstraints() {
        
        self.removeConstraints([self.minimumHeightConstraint,
                                self.maximumHeightConstraint,
                                self.leadingConstraint,
                                self.trailingConstraint,
                                self.topConstraint,
                                self.widthConstraint
            ].flatMap({ return $0 }))
        
        self.minimumHeightConstraint = self.heightAnchor.constraint(greaterThanOrEqualToConstant: self.minimumHeight)
        self.maximumHeightConstraint = self.heightAnchor.constraint(lessThanOrEqualToConstant: self.maximumHeight)

        self.minimumHeightConstraint?.isActive = true
        self.maximumHeightConstraint?.isActive = true
        
        switch self.layoutMode {
        case .munual:
            self.topConstraint = self.topAnchor.constraint(equalTo: self.superview!.topAnchor, constant: frame.origin.y)
            self.leadingConstraint = self.leadingAnchor.constraint(equalTo: self.superview!.leadingAnchor, constant: frame.origin.x)
            self.widthConstraint = self.widthAnchor.constraint(equalToConstant: frame.size.width)
            self.topConstraint?.isActive = true
            self.leadingConstraint?.isActive = true
            self.widthConstraint?.isActive = true
        case .auto:
            self.leadingConstraint = self.leadingAnchor.constraint(equalTo: self.superview!.leadingAnchor)
            self.trailingConstraint = self.trailingAnchor.constraint(equalTo: self.superview!.trailingAnchor)
            self.leadingConstraint?.isActive = true
            self.trailingConstraint?.isActive = true
        }                
        super.updateConstraints()
    }
    
    // MARK: - 
    
    public func setItems(_ items: [ToolbarItem], animated: Bool) {
        self.stackView.arrangedSubviews.forEach { (view) in
            self.stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        items.forEach { (view) in
            self.stackView.addArrangedSubview(view)
        }
    }
    
    // MARK: -
    
    private(set) lazy var stackView: UIStackView = {
        let view: UIStackView = UIStackView(frame: self.bounds)
        view.axis = .horizontal
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .fillProportionally
        view.alignment = .bottom
        view.spacing = 0
        return view
    }()
    
    private(set) lazy var backgroundView: UIVisualEffectView = {
        let blurEffect: UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let view: UIVisualEffectView = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame = self.bounds
        return view
    }()

}
