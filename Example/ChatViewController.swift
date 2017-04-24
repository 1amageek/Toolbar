//
//  ChatViewController.swift
//  Toolbar
//
//  Created by 1amageek on 2017/04/24.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import UIKit
import Toolbar

class ChatViewController: UIViewController, UITextViewDelegate {

    let toolbar: Toolbar = Toolbar()
    
    var textView: UITextView?
    var item0: ToolbarItem?
    var item1: ToolbarItem?
    
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
    
    var toolbarBottomConstraint: NSLayoutConstraint?
    
    override func loadView() {
        super.loadView()
        self.view.addSubview(toolbar)
        self.toolbarBottomConstraint = self.toolbar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        self.toolbarBottomConstraint?.isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        self.toolbar.maximumHeight = 100
        let view: UITextView = UITextView(frame: .zero)
        view.delegate = self
        view.font = UIFont.systemFont(ofSize: 14)
        self.textView = view
        self.item0 = ToolbarItem(customView: view)
        self.item1 = ToolbarItem(title: "Send", target: self, action: #selector(send))
        self.toolbar.setItems([self.camera, self.picture, self.microphone, self.item0!, self.item1!], animated: false)
        
        
        let gestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hide))
        self.view.addGestureRecognizer(gestureRecognizer)
        
    }
    
    func hide() {
        self.textView?.resignFirstResponder()
        self.camera.setHidden(false, animated: true)
        self.microphone.setHidden(false, animated: true)
        self.picture.setHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    final func keyboardWillShow(notification: Notification) {
        moveToolbar(up: true, notification: notification)
    }
    
    final func keyboardWillHide(notification: Notification) {
        moveToolbar(up: false, notification: notification)
    }
    
    final func moveToolbar(up: Bool, notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        let animationDuration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardHeight = up ? -(userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height : 0
        
        // Animation
        self.toolbarBottomConstraint?.constant = keyboardHeight
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    func send() {
        self.textView?.text = nil
        if let constraint: NSLayoutConstraint = self.constraint {
            self.textView?.removeConstraint(constraint)
        }
        self.toolbar.setNeedsLayout()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.camera.setHidden(true, animated: true)
        self.microphone.setHidden(true, animated: true)
        self.picture.setHidden(true, animated: true)
    }

    func textViewDidChange(_ textView: UITextView) {
        let size: CGSize = textView.sizeThatFits(textView.bounds.size)
        if let constraint: NSLayoutConstraint = self.constraint {
            textView.removeConstraint(constraint)
        }
        self.constraint = textView.heightAnchor.constraint(equalToConstant: size.height)
        self.constraint?.priority = UILayoutPriorityDefaultHigh
        self.constraint?.isActive = true
    }
    
    var constraint: NSLayoutConstraint?
    
}
