//
//  InterfaceController.swift
//  watch Extension
//
//  Created by Kevin_Feng on 16/8/11.
//  Copyright © 2016年 net.FrameFreeze.DingGe. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController,WCSessionDelegate {
    
    @IBOutlet var Score: WKInterfaceLabel!
    
    @IBOutlet var photoButton: WKInterfaceButton!
    
    var shakeDevice:WKInterfaceDevice!
    var sessionWC:WCSession!
    /*
    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activateSession()
            }
        }
    }
 */
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        sessionWC = WCSession.defaultSession()
        sessionWC.delegate = self
        sessionWC.activateSession()
//        if WCSession.isSupported(){
//            let session = WCSession.defaultSession()
//            session.delegate = self
//            session.activateSession()
//        }
        shakeDevice = WKInterfaceDevice()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        NSLog("getNum")
        print("getNUM")
        var num = applicationContext["Score"] as! Double
        Score.setText("\(num)")
        if num >= 80 {
            shakeDevice.playHaptic(WKHapticType.Notification)
        }
    }

    @IBAction func takePhotoBtnClick() {
//        do{
//            Score.setText("ing")
//            try sessionWC.updateApplicationContext(["takePhoto" : true])
//            Score.setText("ed")
//        } catch {
//            NSLog("can't send msg 2 iPhone")
//            print("cannot send msg 2 iPhone")
//        }
//        sessionWC.sendMessage(["takePhoto" : true], replyHandler: { (["takenPhoto" : "yes!"]) -> in
//            
//            }) { (NSError) -> void in
//                
//        }
        //Score.setText("ing")
        sessionWC.sendMessage(["takePhoto" : true], replyHandler: nil, errorHandler: nil)
        //Score.setText("ed")
//        sessionWC.sendMessage(applicationDict,
//                                               replyHandler: { ([String : AnyObject]) → Void in
//                                                // Handle reply
//        })
//        errorHandler: { (NSError) → Void in
            // Handle error
//        });
    }
    
}
