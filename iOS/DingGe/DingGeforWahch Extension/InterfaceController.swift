//
//  InterfaceController.swift
//  DingGeforWahch Extension
//
//  Created by Kevin_Feng on 16/4/23.
//  Copyright © 2016年 FrameFreeze. All rights reserved.
//$(PRODUCT_BUNDLE_IDENTIFIER)
//$(PRODUCT_NAME)

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController,WCSessionDelegate{

    @IBOutlet var scoreWKLabel: WKInterfaceLabel!
    @IBOutlet var takePhotoButton: WKInterfaceButton!
    var shakeDevice:WKInterfaceDevice!
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
       //        WatchSessionManager.sharedManager.addData
        // Configure interface objects here.
    }
    @IBAction func takePhotoButtonClick() {
        try! WCSession.defaultSession().updateApplicationContext(["a":true])
        scoreWKLabel.setText("success")
    }
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
//        WatchSessionManager.sharedManager.startSession()
        if WCSession.isSupported(){
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        shakeDevice = WKInterfaceDevice()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
extension InterfaceController {
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        var num = applicationContext["Score"] as! Double
        scoreWKLabel.setText("\(num)")
        if num >= 75 {
            shakeDevice.playHaptic(WKHapticType.Notification)
        }
    }
}