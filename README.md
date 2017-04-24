# Toolbar

<img src="https://github.com/1amageek/Toolbar/blob/master/Toolbar.png" width="640px">

This toolbar is made with Autolayout.
It works more interactively than UIToolbar.

<img src="https://github.com/1amageek/Toolbar/blob/master/Toolbar.gif" width="320px">

 _Slow Animations Debug mode_

## Installation

__[CocoaPods](https://github.com/cocoapods/cocoapods)__

- Inset `pod 'Toolbar'` to youre Podfile.
- Run `pod install`

## Usage

``` swift

let toolbar: Toolbar = Toolbar()

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
    self.toolbar.setItems([self.camera, self.picture, self.microphone], animated: false)
}


```
