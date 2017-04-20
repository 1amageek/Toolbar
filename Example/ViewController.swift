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
        self.view.addSubview(self.toolbar)
        self.toolbar.frame = CGRect(x: 0, y: 100, width: self.toolbar.bounds.width, height: self.toolbar.bounds.height)
        
        
        let item0: ToolbarItem = ToolbarItem(title: "ssss", target: self, action: #selector(hide))
        let item1: ToolbarItem = ToolbarItem(title: "aaaaaaaa", target: self, action: #selector(hide))
        let item2: ToolbarItem = ToolbarItem(title: "aaaaaaaa", target: self, action: #selector(hide))
        let item3: ToolbarItem = ToolbarItem(title: "aaaaaaaa", target: self, action: #selector(hide))
        self.item0 = item0
        self.toolbar.setItems([item0, item1, item2, item3], animated: true)
        
    }
    
    var item0: ToolbarItem?
    
    func hide() {
        UIView.animate(withDuration: 0.33) { 
            self.item0?.isHidden = true
        }
    }
    
    let toolbar: Toolbar = Toolbar()    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

