//
//  ViewController.swift
//  Example
//
//  Created by 1amageek on 2017/04/20.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        var y: CGFloat = 20
        
        do {
            // FIXME: Spacing bug
            let toolbar: Toolbar = Toolbar()
            self.view.addSubview(toolbar)
            toolbar.frame = CGRect(x: 0, y: y, width: toolbar.bounds.width, height: toolbar.bounds.height)
            let item0: ToolbarItem = ToolbarItem(title: "Flexible Space right", target: nil, action: nil)
            let item1: ToolbarItem = ToolbarItem(spacing: .flexible)
            toolbar.setItems([item0, item1], animated: true)
            y += 50
        }
        
        do {
            // FIXME: Spacing bug
            let toolbar: Toolbar = Toolbar()
            self.view.addSubview(toolbar)
            toolbar.frame = CGRect(x: 0, y: y, width: toolbar.bounds.width, height: toolbar.bounds.height)
            let item0: ToolbarItem = ToolbarItem(spacing: .flexible)
            let item1: ToolbarItem = ToolbarItem(title: "Flexible Space left", target: nil, action: nil)
            toolbar.setItems([item0, item1], animated: true)
            y += 50
        }
        
        do {
            let toolbar: Toolbar = Toolbar()
            self.view.addSubview(toolbar)
            toolbar.frame = CGRect(x: 0, y: y, width: toolbar.bounds.width, height: toolbar.bounds.height)
            let item0: ToolbarItem = ToolbarItem(title: "Button", target: nil, action: nil)
            toolbar.setItems([item0], animated: true)
            y += 50
        }

        do {
            let toolbar: Toolbar = Toolbar()
            self.view.addSubview(toolbar)
            toolbar.frame = CGRect(x: 0, y: y, width: toolbar.bounds.width, height: toolbar.bounds.height)
            let item0: ToolbarItem = ToolbarItem(title: "Button", target: nil, action: nil)
            let item1: ToolbarItem = ToolbarItem(title: "Button", target: nil, action: nil)
            toolbar.setItems([item0, item1], animated: true)
            y += 50
        }
        
        do {
            let toolbar: Toolbar = Toolbar()
            self.view.addSubview(toolbar)
            toolbar.frame = CGRect(x: 0, y: y, width: toolbar.bounds.width, height: toolbar.bounds.height)
            let item0: ToolbarItem = ToolbarItem(title: "Button", target: nil, action: nil)
            let item1: ToolbarItem = ToolbarItem(title: "Button", target: nil, action: nil)
            let item2: ToolbarItem = ToolbarItem(title: "Button", target: nil, action: nil)
            toolbar.setItems([item0, item1, item2], animated: true)
            y += 50
        }
        
        do {
            let toolbar: Toolbar = Toolbar()
            self.view.addSubview(toolbar)
            toolbar.frame = CGRect(x: 0, y: y, width: toolbar.bounds.width, height: toolbar.bounds.height)
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
            toolbar.frame = CGRect(x: 0, y: y, width: toolbar.bounds.width, height: toolbar.bounds.height)
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
            toolbar.frame = CGRect(x: 0, y: y, width: toolbar.bounds.width, height: toolbar.bounds.height)
            let item0: ToolbarItem = ToolbarItem(image: #imageLiteral(resourceName: "instagram"), target: nil, action: nil)
            toolbar.setItems([item0], animated: true)
            self.toolbar = toolbar
            y += 50
        }
        
        do {
            let toolbar: Toolbar = Toolbar()
            self.view.addSubview(toolbar)
            toolbar.frame = CGRect(x: 0, y: y, width: toolbar.bounds.width, height: toolbar.bounds.height)
            let item0: ToolbarItem = ToolbarItem(image: #imageLiteral(resourceName: "instagram"), target: nil, action: nil)
            let item1: ToolbarItem = ToolbarItem(image: #imageLiteral(resourceName: "instagram"), target: nil, action: nil)
            toolbar.setItems([item0, item1], animated: true)
            self.toolbar = toolbar
            y += 50
        }
        
        do {
            let toolbar: Toolbar = Toolbar()
            self.view.addSubview(toolbar)
            toolbar.frame = CGRect(x: 0, y: y, width: toolbar.bounds.width, height: toolbar.bounds.height)
            let item0: ToolbarItem = ToolbarItem(title: "Button", target: self, action: #selector(hide0))
            let item1: ToolbarItem = ToolbarItem(image: #imageLiteral(resourceName: "instagram"), target: self, action: #selector(hide3))
            toolbar.setItems([item0, item1], animated: true)
            y += 50
        }
        
        do {
            let toolbar: Toolbar = Toolbar()
            self.view.addSubview(toolbar)
            toolbar.frame = CGRect(x: 0, y: y, width: toolbar.bounds.width, height: toolbar.bounds.height)
            let item0: ToolbarItem = ToolbarItem(customView: UITextView(frame: .zero))
            let item1: ToolbarItem = ToolbarItem(customView: UITextView(frame: .zero))
            toolbar.setItems([item0, item1], animated: true)
            y += 50
        }
        
        do {
            let toolbar: Toolbar = Toolbar()
            self.view.addSubview(toolbar)
            toolbar.frame = CGRect(x: 0, y: y, width: toolbar.bounds.width, height: toolbar.bounds.height)
            let item0: ToolbarItem = ToolbarItem(customView: UITextView(frame: .zero))
            let item1: ToolbarItem = ToolbarItem(spacing: .fixed)
            item1.width = 30
            let item2: ToolbarItem = ToolbarItem(title: "Button", target: self, action: #selector(hide0))
            toolbar.setItems([item0, item1, item2], animated: true)
            y += 50
        }
        
        do {
            let toolbar: Toolbar = Toolbar()
            self.view.addSubview(toolbar)
            toolbar.frame = CGRect(x: 0, y: y, width: toolbar.bounds.width, height: toolbar.bounds.height)
            let item0: ToolbarItem = ToolbarItem(title: "Button", target: self, action: #selector(hide0))
            let item1: ToolbarItem = ToolbarItem(title: "Button", target: self, action: #selector(hide1))
            let item2: ToolbarItem = ToolbarItem(customView: UITextView(frame: .zero))
            let item3: ToolbarItem = ToolbarItem(image: #imageLiteral(resourceName: "instagram"), target: self, action: #selector(hide3))
            self.item0 = item0
            self.item1 = item1
            self.item2 = item2
            self.item3 = item3
            toolbar.setItems([item0, item1, item2, item3], animated: true)
            y += 50
        }
        
//        do {
//            let toolbar: Toolbar = Toolbar()
//            self.view.addSubview(toolbar)
//            toolbar.frame = CGRect(x: 0, y: y, width: toolbar.bounds.width, height: toolbar.bounds.height)
//            let item0: ToolbarItem = ToolbarItem(title: "Button", target: self, action: #selector(hide0))
//            let item1: ToolbarItem = ToolbarItem(title: "Button", target: self, action: #selector(hide1))
//            let item2: ToolbarItem = ToolbarItem(customView: UITextView(frame: .zero))
//            let item3: ToolbarItem = ToolbarItem(image: #imageLiteral(resourceName: "instagram"), target: self, action: #selector(hide3))
//            self.item0 = item0
//            self.item1 = item1
//            self.item2 = item2
//            self.item3 = item3
//            toolbar.setItems([item0, item1, item2, item3], animated: true)
//            y += 50
//        }
        
    }
    
    var item0: ToolbarItem?
    var item1: ToolbarItem?
    var item2: ToolbarItem?
    var item3: ToolbarItem?
    var toolbar: Toolbar?
    
    func hide0() {
        UIView.animate(withDuration: 0.33) {
            self.item0?.isHidden = true
            self.item1?.setNeedsUpdateConstraints()
            self.toolbar?.layoutIfNeeded()
            self.toolbar?.setNeedsUpdateConstraints()
            self.toolbar?.updateConstraintsIfNeeded()
        }
    }
    
    func hide1() {
        UIView.animate(withDuration: 0.33) {
            self.item0?.isHidden = false
//            self.toolbar?.setNeedsUpdateConstraints()
//            self.toolbar?.updateConstraintsIfNeeded()
            self.toolbar?.layoutIfNeeded()
        }
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
    

}

