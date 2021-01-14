//
//  ViewController.swift
//  Demo
//
//  Created by nori on 2021/01/14.
//

import UIKit
import Toolbar

class ViewController: UIViewController {

    lazy var toolbar: Toolbar = {
        let toolbar: Toolbar = Toolbar([
            Toolbar.Item(title: "BUTTON", target: nil, action: nil),
            Toolbar.Item(title: "BUTTON", target: nil, action: nil),
            Toolbar.Item(title: "BUTTON", target: nil, action: nil)
        ])
        return toolbar
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(self.toolbar)
    }

}
