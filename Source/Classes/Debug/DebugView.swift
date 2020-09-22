//
//  DebugView.swift
//  NowYouSeeMe
//
//  Created by Naveen Chaudhary on 27/05/20.
//  Copyright © 2020 Flipkart. All rights reserved.
//

#if DEBUG
import Foundation

/**
 View for debug options
 
 - Note: Only available in debug mode
 */
internal class DebugView: UIView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var trackingSwitch: UISwitch!
    @IBOutlet private weak var selectiveSwitch: UISwitch!
    @IBOutlet private weak var overlaySwitch: UISwitch!
    @IBOutlet private weak var selectiveView: UIView!
    @IBOutlet private weak var overlayView: UIView!
    @IBOutlet private weak var overlayTips: UIView!

    /**
     Enables/disables tracking
     - Parameters:
        - sender: enable tracking switch
     */
    @IBAction private func trackingSwitchChanged(sender: UISwitch) {
        updateForTracking(sender.isOn)

        if sender.isOn {
            NowYou.seeMe()
        } else {
            NowYou.dont()
        }
    }

    /**
     Enables/disables selective tracking
     - Parameters:
        - sender: enable selective tracking switch
    */
    @IBAction private func selectiveSwitchChanged(sender: UISwitch) {
        updateForSelective(sender.isOn)
    }

    /**
     Enables/disables view overlay
     - Parameters:
        - sender: overlay switch
     */
    @IBAction private func overlaySwitchChanged(sender: UISwitch) {
        updateForOverlay(sender.isOn)
    }

    /**
     Updates view for tracking state
     - Parameters:
        - enabled: boolean indicating whether tracking is enabled
     */
    private func updateForTracking(_ enabled: Bool) {
        // update title
        if enabled {
            titleLabel.text = "Now You See Me!"
        } else {
            titleLabel.text = "Now You Don't!"
        }

        // hide selective tracking view
        selectiveView.isHidden = !enabled

        if !enabled {
            // siwtch off selective tracking if tracking is not enabled
            selectiveSwitch.isOn = false
            updateForSelective(false)
        }
    }

    /**
     Updates view for selective tracking state
     - Parameters:
        - enabled: boolean indicating whether selective tracking is enabled
    */
    private func updateForSelective(_ enabled: Bool) {
        // hide overlay options
        overlayView.isHidden = !enabled

        if !enabled {
            // siwtch off overlay if selective is not enabled
            overlaySwitch.isOn = false
            updateForOverlay(false)
        }

        // update state
        DebugHelper.selectiveTrackingEnabled = enabled
    }

    /**
     Updates view for overlay state
     - Parameters:
        - enabled: boolean indicating whether overlay is enabled
    */
    private func updateForOverlay(_ enabled: Bool) {
        // hide tips
        overlayTips.isHidden = !enabled

        // update state
        DebugHelper.overlayEnabled = enabled
    }

    override internal func awakeFromNib() {
        super.awakeFromNib()

        // setup initial state for overlay view
        overlaySwitch.isOn = DebugHelper.overlayEnabled
        updateForOverlay(DebugHelper.overlayEnabled)

        // setup initial state for selective tracking view
        selectiveSwitch.isOn = DebugHelper.selectiveTrackingEnabled
        updateForSelective(DebugHelper.selectiveTrackingEnabled)

        // setup initial state for enable tracking view
        trackingSwitch.isOn = NowYou.watching
        updateForTracking(NowYou.watching)
    }
}
#endif
