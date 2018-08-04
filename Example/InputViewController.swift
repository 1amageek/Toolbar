//
//  InputViewController.swift
//  Example
//
//  Created by 1amageek on 2018/07/30.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import UIKit

class InputViewController: UITableViewController, UITextViewDelegate {

    let toolbar: Toolbar = Toolbar()

    var textView: UITextView?

    var item0: ToolbarItem?

    var item1: ToolbarItem?

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var inputAccessoryView: UIView? {
        return toolbar
    }

    lazy var camera: ToolbarItem = {
        let item: ToolbarItem = ToolbarItem(image: #imageLiteral(resourceName: "camera"), target: nil, action: nil)
        return item
    }()

    lazy var microphone: ToolbarItem = {
        let item: ToolbarItem = ToolbarItem(image: #imageLiteral(resourceName: "microphone"), target: nil, action: nil)
        return item
    }()

    lazy var picture: ToolbarItem = {
        let item: ToolbarItem = ToolbarItem(image: #imageLiteral(resourceName: "picture"), target: nil, action: nil)
        return item
    }()

    lazy var menu: ToolbarItem = {
        let item: ToolbarItem = ToolbarItem(image: #imageLiteral(resourceName: "Add"), target: self, action: #selector(toggleMenu))
        return item
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.toolbar.maximumHeight = 200
        let view: UITextView = UITextView(frame: .zero)
        view.delegate = self
        view.font = UIFont.systemFont(ofSize: 14)
        self.textView = view
        self.item0 = ToolbarItem(customView: view)
        self.item1 = ToolbarItem(title: "Send", target: self, action: #selector(send))
        self.toolbar.setItems([self.menu, self.camera, self.picture, self.microphone, self.item0!, self.item1!], animated: false)

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }

    @objc func toggleMenu() {
        self.isMenuHidden = !self.isMenuHidden
    }

    var isMenuHidden: Bool = false {
        didSet {
            if oldValue == isMenuHidden {
                return
            }
            self.toolbar.layoutIfNeeded()
            UIView.animate(withDuration: 0.3) {
                self.camera.isHidden = self.isMenuHidden
                self.microphone.isHidden = self.isMenuHidden
                self.picture.isHidden = self.isMenuHidden
                self.toolbar.layoutIfNeeded()
            }
        }
    }

    @objc func send() {
        self.textView?.text = nil
        self.toolbar.setNeedsLayout()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        self.isMenuHidden = true
    }

    var constraint: NSLayoutConstraint?

    func textViewDidChange(_ textView: UITextView) {

        self.item1?.isEnabled = !textView.text.isEmpty

        let size: CGSize = textView.sizeThatFits(textView.bounds.size)
        if let constraint: NSLayoutConstraint = self.constraint {
            textView.removeConstraint(constraint)
        }
        self.constraint = textView.heightAnchor.constraint(equalToConstant: size.height)
        self.constraint?.priority = UILayoutPriority.defaultHigh
        self.constraint?.isActive = true
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
        return cell
    }
}
