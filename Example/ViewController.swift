//
//  ViewController.swift
//  Example
//
//  Created by 1amageek on 2017/04/20.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import UIKit
//import Toolbar

class ViewController: UIViewController, UITextViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        var y: CGFloat = 20
        
        do {
            // FIXME: Spacing bug
            let toolbar: Toolbar = Toolbar()
            self.view.addSubview(toolbar)
            toolbar.frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: Toolbar.defaultHeight)
            let item0: ToolbarItem = ToolbarItem(title: "Button", target: nil, action: nil)
            let item1: ToolbarItem = ToolbarItem(spacing: .flexible)
            toolbar.setItems([item0, item1], animated: true)
            y += 50
        }
        
        do {
            // FIXME: Spacing bug
            let toolbar: Toolbar = Toolbar()
            self.view.addSubview(toolbar)
            toolbar.frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: Toolbar.defaultHeight)
            let item0: ToolbarItem = ToolbarItem(spacing: .flexible)
            let item1: ToolbarItem = ToolbarItem(title: "Button", target: nil, action: nil)
            toolbar.setItems([item0, item1], animated: true)
            y += 50
        }
        
        do {
            let toolbar: Toolbar = Toolbar()
            self.view.addSubview(toolbar)
            toolbar.frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: Toolbar.defaultHeight)
            let item0: ToolbarItem = ToolbarItem(title: "Button", target: nil, action: nil)
            toolbar.setItems([item0], animated: true)
            y += 50
        }

        do {
            let toolbar: Toolbar = Toolbar()
            self.view.addSubview(toolbar)
            toolbar.frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: Toolbar.defaultHeight)
            let item0: ToolbarItem = ToolbarItem(title: "Button", target: nil, action: nil)
            let item1: ToolbarItem = ToolbarItem(title: "Button", target: nil, action: nil)
            toolbar.setItems([item0, item1], animated: true)
            y += 50
        }
        
        do {
            let toolbar: Toolbar = Toolbar()
            self.view.addSubview(toolbar)
            toolbar.frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: Toolbar.defaultHeight)
            let item0: ToolbarItem = ToolbarItem(title: "Button", target: nil, action: nil)
            let item1: ToolbarItem = ToolbarItem(title: "Button", target: nil, action: nil)
            let item2: ToolbarItem = ToolbarItem(title: "Button", target: nil, action: nil)
            toolbar.setItems([item0, item1, item2], animated: true)
            y += 50
        }
        
        do {
            let toolbar: Toolbar = Toolbar()
            self.view.addSubview(toolbar)
            toolbar.frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: Toolbar.defaultHeight)
            let item0: ToolbarItem = ToolbarItem(title: "Button", target: nil, action: nil)
            let item1: ToolbarItem = ToolbarItem(title: "Button", target: nil, action: nil)
            let item2: ToolbarItem = ToolbarItem(title: "Button", target: nil, action: nil)
            let item3: ToolbarItem = ToolbarItem(title: "Button", target: nil, action: nil)
            toolbar.setItems([item0, item1, item2, item3], animated: true)
            y += 50
        }
        
        do {
            let toolbar: Toolbar = Toolbar()
            self.view.addSubview(toolbar)
            toolbar.frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: Toolbar.defaultHeight)
            let item0: ToolbarItem = ToolbarItem(title: "Button", target: nil, action: nil)
            let item1: ToolbarItem = ToolbarItem(title: "Button", target: nil, action: nil)
            let item2: ToolbarItem = ToolbarItem(title: "Button", target: nil, action: nil)
            let item3: ToolbarItem = ToolbarItem(title: "Button", target: nil, action: nil)
            let item4: ToolbarItem = ToolbarItem(title: "Button", target: nil, action: nil)
            toolbar.setItems([item0, item1, item2, item3, item4], animated: true)
            y += 50
        }
        
        do {
            let toolbar: Toolbar = Toolbar()
            self.view.addSubview(toolbar)
            toolbar.frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: Toolbar.defaultHeight)
            let item0: ToolbarItem = ToolbarItem(image: #imageLiteral(resourceName: "instagram"), target: nil, action: nil)
            toolbar.setItems([item0], animated: true)
            y += 50
        }
        
        do {
            let toolbar: Toolbar = Toolbar()
            self.view.addSubview(toolbar)
            toolbar.frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: Toolbar.defaultHeight)
            let item0: ToolbarItem = ToolbarItem(image: #imageLiteral(resourceName: "instagram"), target: nil, action: nil)
            let item1: ToolbarItem = ToolbarItem(image: #imageLiteral(resourceName: "instagram"), target: nil, action: nil)
            toolbar.setItems([item0, item1], animated: true)
            y += 50
        }
        
        do {
            let toolbar: Toolbar = Toolbar()
            self.view.addSubview(toolbar)
            toolbar.frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: Toolbar.defaultHeight)
            let item0: ToolbarItem = ToolbarItem(title: "Button", target: self, action: #selector(hide0))
            let item1: ToolbarItem = ToolbarItem(image: #imageLiteral(resourceName: "instagram"), target: self, action: #selector(hide3))
            toolbar.setItems([item0, item1], animated: true)
            y += 50
        }
        
        do {
            let toolbar: Toolbar = Toolbar()
            self.view.addSubview(toolbar)
            toolbar.frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: Toolbar.defaultHeight)
            let item0: ToolbarItem = ToolbarItem(customView: UITextView(frame: .zero))
            let item1: ToolbarItem = ToolbarItem(customView: UITextView(frame: .zero))
            toolbar.setItems([item0, item1], animated: true)
            y += 50
        }
        
        do {
            let toolbar: Toolbar = Toolbar()
            self.view.addSubview(toolbar)
            toolbar.frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: Toolbar.defaultHeight)
            let item0: ToolbarItem = ToolbarItem(customView: UITextView(frame: .zero))
            let item1: ToolbarItem = ToolbarItem(spacing: .fixed)
            item1.width = 30
            let item2: ToolbarItem = ToolbarItem(title: "Button", target: self, action: #selector(hide0))
            toolbar.setItems([item0, item1, item2], animated: true)
            y += 50
        }
 
        do {
            let toolbar: Toolbar = Toolbar()
            toolbar.maximumHeight = 100
            self.view.addSubview(toolbar)
            toolbar.frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: Toolbar.defaultHeight)
            let item0: ToolbarItem = ToolbarItem(title: "Button", target: self, action: #selector(hide0))
            let item1: ToolbarItem = ToolbarItem(title: "Button", target: self, action: #selector(hide1))
            let view: UITextView = UITextView(frame: .zero)
            view.delegate = self
            let item2: ToolbarItem = ToolbarItem(customView: view)
            let item3: ToolbarItem = ToolbarItem(image: #imageLiteral(resourceName: "instagram"), target: self, action: #selector(hide3))
            self.item0 = item0
            self.item1 = item1
            self.item2 = item2
            self.item3 = item3
            toolbar.setItems([item0, item1, item2, item3], animated: true)
            self.toolbar = toolbar
            y += 50
        }
        
    }
    
    var item0: ToolbarItem?
    var item1: ToolbarItem?
    var item2: ToolbarItem?
    var item3: ToolbarItem?
    var toolbar: Toolbar?
    
    func hide0() {
        self.item0?.setHidden(true, animated: true)
    }
    
    func hide1() {
        self.item0?.setHidden(false, animated: true)
    }
    
    func hide2() {
        UIView.animate(withDuration: 0.33) {
            self.item2?.isHidden = true
        }
    }
    
    func hide3() {
        UIView.animate(withDuration: 0.33) {
            self.item3?.isHidden = true
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print(textView.sizeThatFits(textView.bounds.size))
        let size: CGSize = textView.sizeThatFits(textView.bounds.size)
        if let constraint: NSLayoutConstraint = self.constraint {
            textView.removeConstraint(constraint)
        }
        self.constraint = textView.heightAnchor.constraint(equalToConstant: size.height)
        self.constraint?.priority = UILayoutPriorityDefaultHigh
        self.constraint?.isActive = true
        self.toolbar?.layoutIfNeeded()
    }

    var constraint: NSLayoutConstraint?
    
}
