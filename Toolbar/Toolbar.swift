//
//  Toolbar.swift
//  Toolbar
//
//  Created by 1amageek on 2017/04/20.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import UIKit

public class Toolbar: UIView {

    public override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    public static let defaultHeight: CGFloat = 44

    public var axis: NSLayoutConstraint.Axis = .horizontal {
        didSet {
            stackView.axis = axis
            switch axis {
            case .horizontal: layoutHorizontal()
            case .vertical: layoutVertical()
            }
            setNeedsLayout()
        }
    }
    
    /// Maximum value of high value of toolbar
    public var maximumHeight: CGFloat = UIScreen.main.bounds.height
    
    public var minimumHeight: CGFloat = Toolbar.defaultHeight

    public var padding: UIEdgeInsets = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)

    public var isTranslucent: Bool = true {
        didSet {
            if isTranslucent {
                self.backgroundView.isHidden = true
                self.backgroundColor = .white
            } else {
                self.backgroundView.isHidden = false
                self.backgroundColor = .clear
            }
        }
    }
    
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

    private var bottomConstraint: NSLayoutConstraint?

    private var cachedIntrinsicContentSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: Toolbar.defaultHeight)
    
    // MARK: - Init
    
    /**
     Initialize in autolayout mode.
    */
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(self.backgroundView)
        self.addSubview(self.stackView)
        self.backgroundColor = .clear
        self.isOpaque = false
        self.translatesAutoresizingMaskIntoConstraints = false

        self.backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        self.backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        self.backgroundView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        self.backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.padding.left).isActive = true
        self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: self.padding.right).isActive = true

        if #available(iOS 11.0, *) {
            self.stackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: self.padding.top).isActive = true
            self.stackView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -self.padding.bottom).isActive = true
            let stackViewBottomConstraint: NSLayoutConstraint = self.stackView.bottomAnchor.constraint(greaterThanOrEqualTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -self.padding.bottom)
            stackViewBottomConstraint.priority = UILayoutPriority(rawValue: 250)
            stackViewBottomConstraint.isActive = true
        } else {
            self.stackView.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor, constant: self.padding.top).isActive = true
            let stackViewBottomConstraint: NSLayoutConstraint = self.stackView.bottomAnchor.constraint(greaterThanOrEqualTo: self.layoutMarginsGuide.bottomAnchor, constant: -self.padding.bottom)
            stackViewBottomConstraint.priority = UILayoutPriority(rawValue: 250)
            stackViewBottomConstraint.isActive = true
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if self.superview != nil {
            self.setConstraints()
        }
    }

    private func setConstraints() {
        self.removeConstraints([self.minimumHeightConstraint,
                                self.maximumHeightConstraint,
                                self.leadingConstraint,
                                self.trailingConstraint,
                                self.topConstraint,
                                self.bottomConstraint,
                                self.widthConstraint
            ].compactMap({ return $0 }))

        switch axis {
        case .horizontal:
            self.minimumHeightConstraint = self.heightAnchor.constraint(greaterThanOrEqualToConstant: self.minimumHeight)
            self.maximumHeightConstraint = self.heightAnchor.constraint(lessThanOrEqualToConstant: self.maximumHeight)
            self.minimumHeightConstraint?.isActive = true
            self.maximumHeightConstraint?.isActive = true
            self.leadingConstraint = self.leadingAnchor.constraint(equalTo: self.superview!.leadingAnchor)
            self.trailingConstraint = self.trailingAnchor.constraint(equalTo: self.superview!.trailingAnchor)
            self.leadingConstraint?.isActive = true
            self.trailingConstraint?.isActive = true
        case .vertical:
            self.leadingConstraint = self.leadingAnchor.constraint(equalTo: self.superview!.leadingAnchor)
            self.trailingConstraint = self.trailingAnchor.constraint(equalTo: self.superview!.trailingAnchor)
            self.leadingConstraint?.isActive = true
            self.trailingConstraint?.isActive = true
        }
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if #available(iOS 11.0, *) {
            if let window = self.window {
                let constraint: NSLayoutConstraint = self.stackView.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: window.safeAreaLayoutGuide.bottomAnchor, multiplier: 1)
                constraint.constant = -padding.bottom
                constraint.priority = UILayoutPriority(rawValue: 750)
                constraint.isActive = true
            }
        }
    }

    public override var intrinsicContentSize: CGSize {
        return self.cachedIntrinsicContentSize
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

    private func layoutHorizontal() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally
        stackView.alignment = .bottom
        stackView.spacing = 0
    }

    private func layoutVertical() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 0
    }

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
        let blurEffect: UIBlurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
        let view: UIVisualEffectView = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame = self.bounds
        return view
    }()
}
