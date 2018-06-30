# Toolbar

<img src="https://github.com/1amageek/Toolbar/blob/master/Toolbar.png" width="640px">

 [![Version](http://img.shields.io/cocoapods/v/Toolbar.svg)](http://cocoapods.org/?q=Toolbar)
 [![Platform](http://img.shields.io/cocoapods/p/Toolbar.svg)](http://cocoapods.org/?q=Toolbar)
 [![Downloads](https://img.shields.io/cocoapods/dt/Toolbar.svg?label=Total%20Downloads&colorB=28B9FE)](https://cocoapods.org/pods/Toolbar)

This toolbar is made with Autolayout.
It works more interactively than UIToolbar.

<img src="https://github.com/1amageek/pls_donate/blob/master/kyash.jpg" width="200px">

Please Donate

<img src="https://github.com/1amageek/Toolbar/blob/master/Toolbar.gif" width="320px">

 _Slow Animations Debug mode_
 
If you want a Toolbar that works with the keyboard, please see here.
https://github.com/1amageek/OnTheKeyboard

## Installation

__[CocoaPods](https://github.com/cocoapods/cocoapods)__

- Inset `pod 'Toolbar'` to your Podfile.
- Run `pod install`

## Usage

Height and Width of the Toolbar are determined automatically.
Do not set frame.

Initialization.
```
let toolbar: Toolbar = Toolbar()
```

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

### Hide items
``` Swift
func hideItems() {
    self.camera.setHidden(false, animated: true)
    self.microphone.setHidden(false, animated: true)
    self.picture.setHidden(false, animated: true)
}
```

### Stretchable TextView

You can control the height by setting `maximumHeight`.

``` Swift
// ViewController

override func viewDidLoad() {
    super.viewDidLoad()
    self.toolbar.maximumHeight = 100
    let textView: UITextView = UITextView(frame: .zero)
    textView.delegate = self
    textView.font = UIFont.systemFont(ofSize: 14)
    self.toolbar.setItems([textView], animated: false)
}

// UITextViewDelegate
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

```
