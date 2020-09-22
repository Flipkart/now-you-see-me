//
//  DebugHelper.swift
//  NowYouSeeMe
//
//  Created by Naveen Chaudhary on 27/05/20.
//  Copyright © 2020 Flipkart. All rights reserved.
//

#if DEBUG
import UIKit
import FCChatHeads

/**
 Notification keys for handling debugging support
 
 - Note: Only available in DEBUG mode
*/
internal class DebugNotifications {
    /**
     Notification for showing overlays
     */
    static internal let displayOverlay: Notification.Name = Notification.Name("NowYouSeeMe.displayOverlay")

    /**
     Notification for hiding overlays
     */
    static internal let hideOverlay: Notification.Name = Notification.Name("NowYouSeeMe.hideOverlay")
}

/**
 Displays and handles debug options
 
 - Note: This class is only available in DEBUG mode
 */
internal class DebugHelper: NSObject {
    /**
     Boolean indicating whether view tracking is enabled on all views or on selective views only
     */
    static internal var selectiveTrackingEnabled: Bool = false

    /**
     Booleam indicating whether overlays are visible on the views
     */
    static internal var overlayEnabled: Bool = false {
        didSet {
            guard oldValue != overlayEnabled else {
                return
            }
            // fire notifications to hide/unhide view overlays
            if overlayEnabled {
                NotificationCenter.default.post(name: DebugNotifications.displayOverlay, object: nil)
            } else {
                NotificationCenter.default.post(name: DebugNotifications.hideOverlay, object: nil)
            }
        }
    }

    /**
     Shared instance of Debug Helper
     */
    static internal let shared: DebugHelper = DebugHelper()

    /**
     Private initializer, use ```shared``` instance instead
     */
    private override init() {
        super.init()
    }

    /**
     Boolean indicating whether debug options chat head is shown
     */
    private var isShown: Bool = false

    /**
     Chat head controller which displays the debug options
     */
    private var chatHead: FCChatHeadsController?

    /**
     Displays chat head for debug options
     */
    internal func show() {
        guard !isShown, UIApplication.shared.keyWindow != nil else {
            return
        }
        // update flag
        isShown = true

        // create chat head image
        let bundle: Bundle = Bundle(for: Self.self)
        let imageView: UIImageView = UIImageView(image: UIImage(named: "Logo", in: bundle, compatibleWith: nil))
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true

        // create and display chat head with debug options
        let chatHead: FCChatHeadsController = FCChatHeadsController()
        chatHead.datasource = self
        chatHead.delegate = self
        chatHead.presentChatHead(with: imageView, chatID: "NowYouSeeMe.debugView")
        self.chatHead = chatHead
    }
}

extension DebugHelper: FCChatHeadsControllerDatasource {
    internal func chatHeadsController(_ chatHeadsController: FCChatHeadsController!, viewForPopoverForChatHeadWithChatID chatID: String!) -> UIView! {
        // provide view for debug options
        let bundle: Bundle = Bundle(for: Self.self)
        let myView: DebugView? = bundle.loadNibNamed("DebugView", owner: nil, options: nil)?.first as? DebugView

        return myView ?? UIView()
    }
}

extension DebugHelper: FCChatHeadsControllerDelegate {
    internal func chatHeadsControllerDidDisplayChatView(_ chatHeadsController: FCChatHeadsController!) {
    }

    internal func chatHeadsController(_ chController: FCChatHeadsController!, willDismissPopoverForChatID chatID: String!) {
    }

    internal func chatHeadsController(_ chController: FCChatHeadsController!, didDismissPopoverForChatID chatID: String!) {
    }

    internal func chatHeadsController(_ chController: FCChatHeadsController!, didRemoveChatHeadWithChatID chatID: String!) {
        // reset flag so that we can create a new chathead on demand
        isShown = false
    }
}
#endif
