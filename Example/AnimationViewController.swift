//
//  AnimationViewController.swift
//  Example
//
//  Created by 1amageek on 2018/01/18.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import UIKit

class AnimationViewController: UIViewController {

    var item0: ToolbarItem?
    var item1: ToolbarItem?

    var toolbar: Toolbar?

    override func viewDidLoad() {
        super.viewDidLoad()

        let button: UIButton = UIButton(type: .system)
        button.setTitle("Animation Button", for: UIControlState.normal)
        self.view.addSubview(button)
        button.sizeToFit()
        button.center = self.view.center
        button.addTarget(self, action: #selector(hide0), for: UIControlEvents.touchUpInside)

        let toolbar: Toolbar = Toolbar()
        self.view.addSubview(toolbar)
        if #available(iOS 11.0, *) {
            toolbar.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            toolbar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 100).isActive = true
        } else {
            toolbar.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 100).isActive = true
        }
        self.item0 = ToolbarItem(title: "Button", target: nil, action: nil)
        self.item1 = ToolbarItem(image: #imageLiteral(resourceName: "instagram"), target: nil, action: nil)
        toolbar.setItems([self.item0!, self.item1!], animated: false)
    }

    @objc func hide0() {
        self.item0?.setHidden(!self.item0!.isHidden, animated: true)
    }

    @objc func hide1() {
        self.item0?.setHidden(!self.item1!.isHidden, animated: true)
    }
}
