//
//  NBMaterialDialog.swift
//  NBMaterialDialogIOS
//
//  Created by Torstein Skulbru on 02/05/15.
//  Copyright (c) 2015 Torstein Skulbru. All rights reserved.
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Torstein Skulbru
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


import BFPaperButton

/**
Simple material dialog class
*/
@objc public class NBMaterialDialog : UIViewController {
    // MARK: - Class variables
    private var overlay: UIView?
    private var titleLabel: UILabel?
    private var containerView: UIView = UIView()
    private var contentView: UIView = UIView()
    private var okButton: BFPaperButton?
    private var cancelButton: BFPaperButton?
    private var tapGesture: UITapGestureRecognizer!
    private var backgroundColor: UIColor!
    private var windowView: UIView!

    private var isStacked: Bool = false

    private let kBackgroundTransparency: CGFloat = 0.7
    private let kPadding: CGFloat = 16.0
    private let kWidthMargin: CGFloat = 40.0
    private let kHeightMargin: CGFloat = 24.0
    internal var kMinimumHeight: CGFloat {
        return 120.0
    }

    private var _kMaxHeight: CGFloat?
    internal var kMaxHeight: CGFloat {
        if _kMaxHeight == nil {
            let window = UIScreen.mainScreen().bounds
            _kMaxHeight = window.height - kHeightMargin - kHeightMargin
        }
        return _kMaxHeight!
    }

    internal var strongSelf: NBMaterialDialog?
    internal var userAction: ((isOtherButton: Bool) -> Void)?
    internal var constraintViews: [String: AnyObject]!

    // MARK: - Constructors
    public convenience init() {
        self.init(color: UIColor.whiteColor())
    }
    
    public convenience init(color: UIColor) {
        self.init(nibName: nil, bundle:nil)
        view.frame = UIScreen.mainScreen().bounds
        view.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        view.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:kBackgroundTransparency)
        backgroundColor = color
        setupContainerView()
        view.addSubview(containerView)
        
        //Retaining itself strongly so can exist without strong refrence
        strongSelf = self
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Dialog Lifecycle

    /**
        Hides the dialog
    */
    public func hideDialog() {
        hideDialog(-1)
    }

    /**
    Hides the dialog, sending a callback if provided when dialog was shown
    :params: buttonIndex The tag index of the button which was clicked
    */
    internal func hideDialog(buttonIndex: Int) {

        if buttonIndex >= 0 {
            if let userAction = userAction {
                userAction(isOtherButton: buttonIndex > 0)
            }
        }

        view.removeGestureRecognizer(tapGesture)

        for childView in view.subviews {
            childView.removeFromSuperview()
        }

        view.removeFromSuperview()
        strongSelf = nil
    }

    /**
    Displays a simple dialog using a title and a view with the content you need

    :param: windowView The window which the dialog is to be attached
    :param: title The dialog title
    :param: content A custom content view
    */
    public func showDialog(windowView: UIView, title: String?, content: UIView) -> NBMaterialDialog {
        return showDialog(windowView, title: title, content: content, dialogHeight: nil, okButtonTitle: nil, action: nil, cancelButtonTitle: nil, stackedButtons: false)
    }

    /**
    Displays a simple dialog using a title and a view with the content you need

    :param: windowView The window which the dialog is to be attached
    :param: title The dialog title
    :param: content A custom content view
    :param: dialogHeight The height of the dialog
    */
    public func showDialog(windowView: UIView, title: String?, content: UIView, dialogHeight: CGFloat?) -> NBMaterialDialog {
        return showDialog(windowView, title: title, content: content, dialogHeight: dialogHeight, okButtonTitle: nil, action: nil, cancelButtonTitle: nil, stackedButtons: false)
    }

    /**
    Displays a simple dialog using a title and a view with the content you need

    :param: windowView The window which the dialog is to be attached
    :param: title The dialog title
    :param: content A custom content view
    :param: dialogHeight The height of the dialog
    :param: okButtonTitle The title of the last button (far-most right), normally OK, CLOSE or YES (positive response).
    */
    public func showDialog(windowView: UIView, title: String?, content: UIView, dialogHeight: CGFloat?, okButtonTitle: String?) -> NBMaterialDialog {
        return showDialog(windowView, title: title, content: content, dialogHeight: dialogHeight, okButtonTitle: okButtonTitle, action: nil, cancelButtonTitle: nil, stackedButtons: false)
    }

    /**
    Displays a simple dialog using a title and a view with the content you need

    :param: windowView The window which the dialog is to be attached
    :param: title The dialog title
    :param: content A custom content view
    :param: dialogHeight The height of the dialog
    :param: okButtonTitle The title of the last button (far-most right), normally OK, CLOSE or YES (positive response).
    :param: action The action you wish to invoke when a button is clicked
    */
    public func showDialog(windowView: UIView, title: String?, content: UIView, dialogHeight: CGFloat?, okButtonTitle: String?, action: ((isOtherButton: Bool) -> Void)?) -> NBMaterialDialog {
        return showDialog(windowView, title: title, content: content, dialogHeight: dialogHeight, okButtonTitle: okButtonTitle, action: action, cancelButtonTitle: nil, stackedButtons: false)
    }

    /**
    Displays a simple dialog using a title and a view with the content you need

    :param: windowView The window which the dialog is to be attached
    :param: title The dialog title
    :param: content A custom content view
    :param: dialogHeight The height of the dialog
    :param: okButtonTitle The title of the last button (far-most right), normally OK, CLOSE or YES (positive response).
    :param: action The action you wish to invoke when a button is clicked
    */
    public func showDialog(windowView: UIView, title: String?, content: UIView, dialogHeight: CGFloat?, okButtonTitle: String?, action: ((isOtherButton: Bool) -> Void)?, cancelButtonTitle: String?) -> NBMaterialDialog {
        return showDialog(windowView, title: title, content: content, dialogHeight: dialogHeight, okButtonTitle: okButtonTitle, action: action, cancelButtonTitle: cancelButtonTitle, stackedButtons: false)
    }

    /**
    Displays a simple dialog using a title and a view with the content you need

    :param: windowView The window which the dialog is to be attached
    :param: title The dialog title
    :param: content A custom content view
    :param: dialogHeight The height of the dialog
    :param: okButtonTitle The title of the last button (far-most right), normally OK, CLOSE or YES (positive response).
    :param: action The action you wish to invoke when a button is clicked
    :param: cancelButtonTitle The title of the first button (the left button), normally CANCEL or NO (negative response)
    :param: stackedButtons Defines if a stackd button view should be used
    */
    public func showDialog(windowView: UIView, title: String?, content: UIView, dialogHeight: CGFloat?, okButtonTitle: String?, action: ((isOtherButton: Bool) -> Void)?, cancelButtonTitle: String?, stackedButtons: Bool) -> NBMaterialDialog {

        isStacked = stackedButtons

        var totalButtonTitleLength: CGFloat = 0.0

        self.windowView = windowView
        
        let windowSize = windowView.bounds

        windowView.addSubview(view)
        view.frame = windowView.bounds
        tapGesture = UITapGestureRecognizer(target: self, action: "tappedBg")
        view.addGestureRecognizer(tapGesture)

        setupContainerView()
        // Add content to contentView
        contentView = content
        setupContentView()


        if let title = title {
            setupTitleLabelWithTitle(title)
        }

        if let okButtonTitle = okButtonTitle {
            totalButtonTitleLength += (okButtonTitle.uppercaseString as NSString).sizeWithAttributes([NSFontAttributeName: UIFont.robotoMediumOfSize(14)]).width + 8
            if let cancelButtonTitle = cancelButtonTitle {
                totalButtonTitleLength += (cancelButtonTitle.uppercaseString as NSString).sizeWithAttributes([NSFontAttributeName: UIFont.robotoMediumOfSize(14)]).width + 8
            }

            // Calculate if the combined button title lengths are longer than max allowed for this dialog, if so use stacked buttons.
            let buttonTotalMaxLength: CGFloat = (windowSize.width - (kWidthMargin*2)) - 16 - 16 - 8
            if totalButtonTitleLength > buttonTotalMaxLength {
                isStacked = true
            }
        }

        // Always display a close/ok button, but setting a title is optional.
        if let okButtonTitle = okButtonTitle {
            setupButtonWithTitle(okButtonTitle, button: &okButton, isStacked: isStacked)
            if let okButton = okButton {
                okButton.tag = 0
                okButton.addTarget(self, action: "pressedAnyButton:", forControlEvents: UIControlEvents.TouchUpInside)
            }
        }

        if let cancelButtonTitle = cancelButtonTitle {
            setupButtonWithTitle(cancelButtonTitle, button: &cancelButton, isStacked: isStacked)
            if let cancelButton = cancelButton {
                cancelButton.tag = 1
                cancelButton.addTarget(self, action: "pressedAnyButton:", forControlEvents: UIControlEvents.TouchUpInside)
            }
        }

        userAction = action

        setupViewConstraints()

        // To get dynamic width to work we need to comment this out and uncomment the stuff in setupViewConstraints. But its currently not working..
        containerView.frame = CGRectMake(kWidthMargin, (windowSize.height - (dialogHeight ?? kMinimumHeight)) / 2, windowSize.width - (kWidthMargin*2), fmin(kMaxHeight, (dialogHeight ?? kMinimumHeight)))
        containerView.clipsToBounds = true
        return self
    }

    // MARK: - View lifecycle
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var sz = UIScreen.mainScreen().bounds.size
        let sver = UIDevice.currentDevice().systemVersion as NSString
        let ver = sver.floatValue
        if ver < 8.0 {
            // iOS versions before 7.0 did not switch the width and height on device roration
            if UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation) {
                let ssz = sz
                sz = CGSize(width:ssz.height, height:ssz.width)
            }
        }
    }

    // MARK: - User interaction
    /**
    Invoked when the user taps the background (anywhere except the dialog)
    */
    internal func tappedBg() {
        hideDialog(-1)
    }

    /**
    Invoked when a button is pressed

    :param: sender The button clicked
    */
    internal func pressedAnyButton(sender: AnyObject) {
        self.hideDialog((sender as! UIButton).tag)
    }

    // MARK: - View Constraints
    /**
    Sets up the constraints which defines the dialog
    */
    internal func setupViewConstraints() {
        if constraintViews == nil {
            constraintViews = ["content": contentView, "containerView": containerView, "window": windowView]
        }
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-24-[content]-24-|", options: NSLayoutFormatOptions(0), metrics: nil, views: constraintViews))
        if let titleLabel = self.titleLabel {
            constraintViews["title"] = titleLabel
            containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-24-[title]-24-[content]", options: NSLayoutFormatOptions(0), metrics: nil, views: constraintViews))
            containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-24-[title]-24-|", options: NSLayoutFormatOptions(0), metrics: nil, views: constraintViews))
        } else {
            containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-24-[content]", options: NSLayoutFormatOptions(0), metrics: nil, views: constraintViews))
        }

        if okButton != nil || cancelButton != nil {
            if isStacked {
                setupStackedButtonsConstraints()
            } else {
                setupButtonConstraints()
            }
        } else {
            containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[content]-24-|", options: NSLayoutFormatOptions(0), metrics: nil, views: constraintViews))
        }
        // TODO: Fix constraints for the containerView so we can remove the dialogheight var
//
//        let margins = ["kWidthMargin": kWidthMargin, "kMinimumHeight": kMinimumHeight, "kMaxHeight": kMaxHeight]
//        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=kWidthMargin)-[containerView(>=80@1000)]-(>=kWidthMargin)-|", options: NSLayoutFormatOptions(0), metrics: margins, views: constraintViews))
//        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(>=kWidthMargin)-[containerView(>=48@1000)]-(>=kWidthMargin)-|", options: NSLayoutFormatOptions(0), metrics: margins, views: constraintViews))
//        view.addConstraint(NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
//        view.addConstraint(NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
    }

    /**
    Sets up the constraints for normal horizontal styled button layout
    */
    internal func setupButtonConstraints() {
        if let okButton = self.okButton {
            constraintViews["okButton"] = okButton
            containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[content]-24-[okButton(==36)]-8-|", options: NSLayoutFormatOptions(0), metrics: nil, views: constraintViews))

            // The cancel button is only shown when the ok button is visible
            if let cancelButton = self.cancelButton {
                constraintViews["cancelButton"] = cancelButton
                containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[cancelButton(==36)]-8-|", options: NSLayoutFormatOptions(0), metrics: nil, views: constraintViews))
                containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[cancelButton(>=64)]-8-[okButton(>=64)]-8-|", options: NSLayoutFormatOptions(0), metrics: nil, views: constraintViews))
            } else {
                containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[okButton(>=64)]-8-|", options: NSLayoutFormatOptions(0), metrics: nil, views: constraintViews))
            }
        }
    }

    /**
    Sets up the constraints for stacked vertical styled button layout
    */
    internal func setupStackedButtonsConstraints() {
        constraintViews["okButton"] = okButton!
        constraintViews["cancelButton"] = cancelButton!

        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[content]-24-[okButton(==48)]-[cancelButton(==48)]-8-|", options: NSLayoutFormatOptions(0), metrics: nil, views: constraintViews))

        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[okButton]-16-|", options: NSLayoutFormatOptions(0), metrics: nil, views: constraintViews))
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[cancelButton]-16-|", options: NSLayoutFormatOptions(0), metrics: nil, views: constraintViews))
    }

    // MARK: Private view helpers / initializers

    private func setupContainerView() {
        containerView.backgroundColor = backgroundColor
        containerView.layer.cornerRadius = 2.0
        containerView.layer.masksToBounds = true
        containerView.layer.borderWidth = 0.5
        containerView.layer.borderColor = UIColor(hex: 0xCCCCCC, alpha: 1.0).CGColor
        view.addSubview(containerView)
    }

    private func setupTitleLabelWithTitle(title: String) {
        titleLabel = UILabel()
        if let titleLabel = titleLabel {
            titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            titleLabel.font = UIFont.robotoMediumOfSize(20)
            titleLabel.textColor = UIColor(white: 0.13, alpha: 1.0)
            titleLabel.numberOfLines = 0
            titleLabel.text = title
            containerView.addSubview(titleLabel)
        }

    }

    private func setupButtonWithTitle(title: String, inout button: BFPaperButton?, isStacked: Bool) {
        if button == nil {
            button = BFPaperButton()
        }

        if let button = button {
            button.setTranslatesAutoresizingMaskIntoConstraints(false)
            button.setTitle(title.uppercaseString, forState: .Normal)
            button.setTitleColor(NBConfig.AccentColor, forState: .Normal)
            button.isRaised = false
            button.titleLabel?.font = UIFont.robotoMediumOfSize(14)
            if isStacked {
                button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
                button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20)
            } else {
                button.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8)
            }

            containerView.addSubview(button)
        }
    }
    
    private func setupContentView() {
        contentView.backgroundColor = UIColor.clearColor()
        contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        containerView.addSubview(contentView)
    }
}