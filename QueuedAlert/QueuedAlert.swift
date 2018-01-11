//
//  QueuedAlert.swift
//  Meniny Lab
//
//  Blog  : https://meniny.cn
//  Github: https://github.com/Meniny
//
//  No more shall we pray for peace
//  Never ever ask them why
//  No more shall we stop their visions
//  Of selfdestructing genocide
//  Dogs on leads march to war
//  Go ahead end it all...
//
//  Blow up the world
//  The final silence
//  Blow up the world
//  I don't give a damn!
//
//  Screams of terror, panic spreads
//  Bombs are raining from the sky
//  Bodies burning, all is dead
//  There's no place left to hide
//  Dogs on leads march to war
//  Go ahead end it all...
//
//  Blow up the world
//  The final silence
//  Blow up the world
//  I don't give a damn!
//
//  (A voice was heard from the battle field)
//
//  "Couldn't care less for a last goodbye
//  For as I die, so do all my enemies
//  There's no tomorrow, and no more today
//  So let us all fade away..."
//
//  Upon this ball of dirt we lived
//  Darkened clouds now to dwell
//  Wasted years of man's creation
//  The final silence now can tell
//  Dogs on leads march to war
//  Go ahead end it all...
//
//  Blow up the world
//  The final silence
//  Blow up the world
//  I don't give a damn!
//
//  When I wrote this code, only I and God knew what it was.
//  Now, only God knows!
//
//  So if you're done trying 'optimize' this routine (and failed),
//  please increment the following counter
//  as a warning to the next guy:
//
//  total_hours_wasted_here = 0
//
//  Created by Elias Abel on 2018/1/10.
//  Copyright © 2018年 MobiMagic. All rights reserved.
//

import Foundation
import UIKit

fileprivate extension String {
    fileprivate var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

private var alert_semaphore = DispatchSemaphore.init(value: 1)
private var alert_queue = DispatchQueue.init(label: "UIAlertOrderQueue")

public typealias UIAlertActionClosure = (_ index: Int, _ action: UIAlertAction, _ controller: UIAlertController) -> Swift.Void
public typealias UIAlertConfigurationClosure = (_ controller: inout UIAlertController) -> Swift.Void
public typealias UIAlertTextFieldInfo = (title: String?, placeholder: String?)

public extension UIViewController {
    /// Present `UIAlertController`s in queue
    ///
    /// - Parameters:
    ///   - alertContrller: An `UIAlertController` instance
    ///   - animated: If animated
    ///   - completion: Completion closure
    /// - Returns: The controller
    @discardableResult
    public func present(alertContrller: UIAlertController, animated: Bool = true, completion: (() -> Void)? = nil) -> UIAlertController {
        alert_queue.async { [weak self] in
            alert_semaphore.wait()
            DispatchQueue.main.async {
                self?.present(alertContrller, animated: animated, completion: completion)
            }
        }
        return alertContrller
    }
}

public extension UIViewController {
    /// Show an `UIAlertController`
    ///
    /// - Parameters:
    ///   - style: `UIAlertControllerStyle`
    ///   - alertTitle: Title string
    ///   - message: Content text string
    ///   - alignment: Text alignment of message string
    ///   - textFields: Text fields
    ///   - buttons: An array of dismiss button title strings
    ///   - config: Configuration
    ///   - action: Action closure
    @discardableResult
    public func show(_ style: UIAlertControllerStyle,
                     title alertTitle: String?,
                     message: String?,
                     alignment: NSTextAlignment = .center,
                     textFields: [UIAlertTextFieldInfo] = [],
                     buttons: [String] = [],
                     config configuration: UIAlertConfigurationClosure? = nil,
                     action: UIAlertActionClosure? = nil) -> UIAlertController {

        var alertController = UIAlertController.init(title: alertTitle?.localized,
                                                     message: message?.localized,
                                                     preferredStyle: style)
        
        func actionClosure(index: Int) -> ((UIAlertAction) -> Swift.Void) {
            let c: ((UIAlertAction) -> Swift.Void) = { (a) in
                if let act = action {
                    act(index, a, alertController)
                } else {
                    alertController.dismiss(animated: true, completion: nil)
                }
                alert_semaphore.signal()
            }
            return c
        }
        
        if let msg = message {
            let paragraphStyle = NSMutableParagraphStyle.init()
            paragraphStyle.alignment = alignment
            
            let messageText = NSAttributedString.init(
                string: msg.localized,
                attributes: [
                    NSAttributedStringKey.paragraphStyle: paragraphStyle,
                    NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12),
                    NSAttributedStringKey.foregroundColor : UIColor.darkText
                ]
            )
            alertController.setValue(messageText, forKey: "attributedMessage")
        }
        
        for info in textFields {
            alertController.addTextField { (f) in
                if let t = info.title, !t.isEmpty {
                    f.text = t
                }
                if let p = info.placeholder, !p.isEmpty {
                    f.placeholder = p
                }
                f.clearButtonMode = .whileEditing
            }
        }
        
        for btn in buttons {
            guard let index = buttons.index(of: btn) else {
                continue
            }
            let button = UIAlertAction.init(title: btn.localized,
                                            style: .default,
                                            handler: actionClosure(index: index))
            alertController.addAction(button)
        }
        
        if alertController.actions.isEmpty {
            let index = alertController.actions.isEmpty ? 0 : alertController.actions.count
            let button = UIAlertAction.init(title: "Cancel".localized,
                                            style: .cancel,
                                            handler: actionClosure(index: index))
            alertController.addAction(button)
        }
        configuration?(&alertController)
        
        return self.present(alertContrller: alertController, animated: true, completion: nil)
    }
    
    /// Show an `UIAlertController`
    ///
    /// - Parameters:
    ///   - style: `UIAlertControllerStyle`
    ///   - alertTitle: Title string
    ///   - message: Content text string
    ///   - alignment: Text alignment of message string
    ///   - textFields: Text fields
    ///   - buttons: An array of dismiss button title strings
    ///   - config: Configuration
    ///   - action: Action closure
    public func debug(_ style: UIAlertControllerStyle,
                      title alertTitle: String?,
                      message: String?,
                      alignment: NSTextAlignment = .center,
                      textFields: [UIAlertTextFieldInfo] = [],
                      buttons: [String] = [],
                      config: UIAlertConfigurationClosure? = nil,
                      action: UIAlertActionClosure? = nil) {
        #if DEBUG
            self.show(style,
                      title: alertTitle,
                      message: message,
                      alignment: alignment,
                      textFields: textFields,
                      buttons: buttons,
                      config: config,
                      action: action)
        #endif
    }
}

