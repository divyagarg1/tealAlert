//
//  DeviceViewController.swift
//  SwiftStarter
//
//  Created by Stephen Schiffli on 10/20/15.
//  Copyright © 2015 MbientLab Inc. All rights reserved.
//

import UIKit
import MetaWear
import Alamofire

class DeviceViewController: UIViewController {
    @IBOutlet weak var deviceStatus: UILabel!
    
    @IBOutlet var accReaderLabel: UILabel!
    
    var device: MBLMetaWear!
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated);
//        
//        device.addObserver(self, forKeyPath: "state", options: NSKeyValueObservingOptions.new, context: nil)
//        device.connectAsync().success { _ in
//            self.device.led?.flashColorAsync(UIColor.green, withIntensity: 1.0, numberOfFlashes: 3)
//            NSLog("We are connected")
//        }
//    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        device.removeObserver(self, forKeyPath: "state")
        device.led?.flashColorAsync(UIColor.red, withIntensity: 1.0, numberOfFlashes: 3)
        device.disconnectAsync()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        device.addObserver(self, forKeyPath: "state", options: NSKeyValueObservingOptions.new, context: nil)
        device.connect { error in
            NSLog("We are connected")
            
            if let accModule = self.device.accelerometer {
                // Set the output data rate to 25Hz or closet valid value
                accModule.sampleFrequency = 25.0
            } else {
                NSLog("Sorry, no accelerometer");
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        OperationQueue.main.addOperation {
            switch (self.device.state) {
            case .connected:
                self.deviceStatus.text = "Connected";
            case .connecting:
                self.deviceStatus.text = "Connecting";
            case .disconnected:
                self.deviceStatus.text = "Disconnected";
            case .disconnecting:
                self.deviceStatus.text = "Disconnecting";
            case .discovery:
                self.deviceStatus.text = "Discovery";
            }
        }
    }
    @IBAction func startPressed(_ sender: AnyObject) {
        device.accelerometer?.dataReadyEvent.startNotificationsAsync { (obj, error) in
            print(obj)
            self.accReaderLabel.text = "x: \(obj?.x),  y : \(obj?.y) , z : \(obj?.z)"
            
            let headers = [
                "Content-Type": "application/x-www-form-urlencoded"
            ]
            
            let parameters: Parameters = [
                "To": "+15109449190",
                "Body": "Danger"
            ]
            
            if let val = obj?.x {
                if val < 0.026855 {
                    Alamofire.request("http://192.168.1.105:5000/sms", method: .post, parameters: parameters, headers: headers).response {
                        response in print(response)
                        
                    }
                }

            }
                       //Send message
            
            }.success { result in
                print("Successfully subscribed")
            }.failure { error in
                print("Error on subscribe: \(error)")
        }
    }
    @IBAction func stopPressed(_ sender: Any) {
        device.accelerometer?.dataReadyEvent.stopNotificationsAsync().success { result in
            print("Successfully unsubscribed")
            }.failure { error in
                print("Error on unsubscribe: \(error)")
        }
    }
}
