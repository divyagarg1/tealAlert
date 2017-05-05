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
import CoreLocation
import CoreData
import AVFoundation


@available(iOS 10.0, *)
class DeviceViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var navigationBar: UINavigationItem!
   
    @IBOutlet var startButton: UIButton!
 
    @IBOutlet var stopBut: UIButton!
    @IBOutlet var startBut: UIButton!
    @IBOutlet var stopButton: UIButton!
    var savedConfig:Config!
    
    @IBOutlet var status: UILabel!
    
    //For background task
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    // Use the context from AppDelegate to store the config
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var audioPlayer: AVAudioPlayer?
    
    //For timer
    var alertTimer = Timer()
    var alertController: UIAlertController?
    var remainingTime = 0
    var baseMessage: String?

   
    //Display elements
    
    
    let MIN_THRESHOLD = 5
    @IBOutlet weak var deviceStatus: UILabel!

    
    
    //Location variables
    var address: String = ""
    var latitude: String = ""
    var longitude: String = ""
    var horizontalAccuracy: String = ""
    var altitude: String = ""
    var verticalAccuracy: String = ""
    var distance: String = ""
    
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    
    
    var device: MBLMetaWear!
    
    //methods for background task
    
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
       
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        device.removeObserver(self, forKeyPath: "state")
//        device.led?.flashColorAsync(UIColor.red, withIntensity: 1.0, numberOfFlashes: 3)
//        device.disconnectAsync()
    }
    
    override func viewDidLoad() {
        startButton.layer.masksToBounds = true
        startButton.layer.cornerRadius = startButton.frame.width/2
        navigationBar.titleView?.backgroundColor = UIColor.black
        navigationBar.title = "Teal Alert"
//        navigationBar.barTintColor=UIColor.redColor();
        initbutton()

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        device.addObserver(self, forKeyPath: "state", options: NSKeyValueObservingOptions.new, context: nil)
        device.connect { error in
            NSLog("We are connected")
            
            if let accModule = self.device.accelerometer {
                // Set the output data rate to 25Hz or closet valid value
                accModule.sampleFrequency = 40.0
            } else {
                NSLog("Sorry, no accelerometer");
            }
        }

        super.viewWillAppear(animated);
        self.findMyLocation()
        self.fetchConfigFromCoreData()
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
        startButton.isHidden = true
        stopButton.isHidden = false
        status.text = "ON"
        
        startBut.isHidden = true
        stopBut.isHidden = false
        var checker = false;
        
        var listValues = [0.0]
        device.accelerometer?.dataReadyEvent.startNotificationsAsync { (obj, error) in
//            print(obj)
//            self.accReaderLabel.text = "x: \(obj?.x),  y : \(obj?.y) , z : \(obj?.z)"
            
           
            
            if let val = obj?.x {
                let prod = (obj!.x * obj!.x) + (obj!.y * obj!.y) + (obj!.z * obj!.z)
//                print ("Outside")
//                print ("Value:", prod)
//                print("x:",obj!.x)
//                print("y:",obj!.y)
//                print("z:",obj!.z)
//                print("root:",pow(prod, 0.5))
                var root = pow(prod, 0.5)
                if root > Double(self.MIN_THRESHOLD) {
                    print("Inside")
                    print ("Value:", prod)
                    print("x:",obj!.x)
                    print("y:",obj!.y)
                    print("z:",obj!.z)
                    print("root:",pow(prod, 0.5))
//                    let msg = "If you do not cancel, an alert will be sent to your designated contact in following seconds: "
//                    self.showAlertMsg(title: "Fall Alert", message: msg, time: Int(self.savedConfig.alert_time!)!)
                    checker = true;
                    
                }
                var i = 0
                
                if (checker == true) {
                    if (listValues.count < 500) {
                        listValues.append(root)
                        //print (listValues.count)
                    } else {
//                        for(i = 5;i<listValues.count; i += 1) {
                        var sum = 0.0
                        for i in 10...listValues.count-1 {
                            print (listValues[i])
                            sum = sum + listValues[i]
                        }
                        var avg = sum / 490
                        print (avg)
                        if avg <= 2 {
                            print ("Entered 1")
                            checker =  true;
                        } else {
                            print ("Entered 2")
                            checker = false;
                            listValues = [0]
                            print (checker)
                        }

                        if checker == true {
                            let msg = "If you do not cancel, an alert will be sent to your designated contact in following seconds: "
                            self.showAlertMsg(title: "Fall Alert", message: msg, time: Int(self.savedConfig.alert_time!)!)
                            checker = false
                            listValues = [0]
                        }
                        
                    }
                    
                }
                
                
            }
            
            
            }.success { result in
                print("Successfully subscribed")
            }.failure { error in
                print("Error on subscribe: \(error)")
        }
    }
    
    func findMyLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        startLocation = nil
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation])
    {
        let latestLocation: CLLocation = locations[locations.count - 1]
        
        latitude = String(format: "%.4f",
                               latestLocation.coordinate.latitude)
        longitude = String(format: "%.4f",
                                latestLocation.coordinate.longitude)
        
        if startLocation == nil {
            startLocation = latestLocation
        }
        
        let distanceBetween: CLLocationDistance =
            latestLocation.distance(from: startLocation)
        
        distance = String(format: "%.2f", distanceBetween)
        
        print ("Latitude:", latitude)
        print ("Longitude:", longitude)
        
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {
            placemarks, error in
            
            if error == nil && (placemarks?.count)! > 0 {
                let placeMark = (placemarks?.last)! as CLPlacemark
                self.address = "\(placeMark.subThoroughfare!) \(placeMark.thoroughfare!) \(placeMark.locality!)\n\(placeMark.postalCode!) \(placeMark.country!)"
                print ("Address:", self.address)
                self.locationManager.stopUpdatingLocation()
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        
    }

    func initbutton() {
        startButton.isHidden = false
        stopButton.isHidden = true
        startBut.isHidden = false
        stopBut.isHidden = true
    }
    
   
    
    @IBAction func stopPressed(_ sender: Any) {
        status.text = "OFF"
        startButton.isHidden = false
        stopButton.isHidden = true
        startBut.isHidden = false
        stopBut.isHidden = true
        device.accelerometer?.dataReadyEvent.stopNotificationsAsync().success { result in
            print("Successfully unsubscribed")
            }.failure { error in
                print("Error on unsubscribe: \(error)")
        }

    }
    
    
    func presentConfirmationAlert() {
        let alert = UIAlertController(title: "Config Saved to Core Data!", message: "You can view your new dog by clicking `View Dogs`", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func fetchConfigFromCoreData() {
         let context =  appDelegate.persistentContainer.viewContext
        do {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Config")
            let predicate = NSPredicate(format: "id=%@", "1")
            fetchRequest.predicate = predicate
            let results = try context.fetch(fetchRequest)
            
            if(results.count != 0){
                
                savedConfig = results.last as! Config
               
            }
        } catch {
            print("Fetching Config from Core Data failed :( ")
        }
    }
    
    @IBAction func sendMsg(_ sender: UIButton) {
        let msg = "If you do not cancel, an alert will be sent to your designated contact in following seconds: "
        showAlertMsg(title: "Fall Alert", message: msg, time: Int(savedConfig.alert_time!)!)
    }
    
    @IBAction func sendAlert(_ sender: UIButton) {
        let msg = "If you do not cancel, an alert will be sent to your designated contact in following seconds: "
        showAlertMsg(title: "Fall Alert", message: msg, time: Int(savedConfig.alert_time!)!)
    }
    
    func showAlertMsg(title: String, message: String, time: Int) {
        
        guard (self.alertController == nil) else {
            print("Alert already displayed")
            return
        }
        
        self.baseMessage = message
        self.remainingTime = time
        playSound()
        self.alertController = UIAlertController(title: title, message: self.alertMessage(), preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("Alert was cancelled")
            self.alertController=nil;
            self.alertTimer.invalidate()
            self.audioPlayer?.stop()
            
        }

        self.alertController!.addAction(cancelAction)
        
        self.alertTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.countDown), userInfo: nil, repeats: true)
        
        self.present(self.alertController!, animated: true, completion: nil)
    }
    
    func countDown() {
        self.remainingTime -= 1
        if (self.remainingTime < 0) {
            self.alertTimer.invalidate()
            self.alertController!.dismiss(animated: true, completion: {
            self.alertController = nil
            self.audioPlayer?.stop()
            self.sendMessage()
            })
        } else {
            self.alertController!.message = self.alertMessage()
        }
        
    }
    
    func alertMessage() -> String {
        var message=""
        if let baseMessage=self.baseMessage {
            message=baseMessage+" "
        }
        return(message+"\(self.remainingTime)")
    }
    
    
    
    func showAlert() {
        playSound()
        let alert = UIAlertController(title: "Fall Alert", message: "If you do not cancel, an alert will be sent to your designated contact in 2 min", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel Alert", style: UIAlertActionStyle.default, handler: {action in self.stopAlert()}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func playSound() {
        //vibrate phone first
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        //set vibrate callback
        AudioServicesAddSystemSoundCompletion(SystemSoundID(kSystemSoundID_Vibrate),nil,
                                              nil,
                                              { (_:SystemSoundID, _:UnsafeMutableRawPointer?) -> Void in
                                                print("callback", terminator: "") //todo
        },
                                              nil)
        let url = URL(
            fileURLWithPath: Bundle.main.path(forResource: "alarm1", ofType: "mp3")!)
        
        var error: NSError?
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch let error1 as NSError {
            error = error1
            audioPlayer = nil
        }
        
        audioPlayer!.numberOfLoops = -1
        audioPlayer!.play()
    }

    func stopAlert() {
        audioPlayer?.stop()
    }
    
    func sendMessage() {
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        var body = "Hi " + savedConfig.contact_name! + ", "
        body = body + savedConfig.name! + " is in danger. They are at below location: " + self.address

        
        let parameters: Parameters = [
            "To": savedConfig.contact_phone!,
            "ContactName": savedConfig.contact_name!,
            "Name": savedConfig.name!,
            "Latitude": latitude,
            "Longitude": longitude,
            "Body": body
        ]
        
        print(parameters)
        
        Alamofire.request("https://tealalert.herokuapp.com/sms", method: .post, parameters: parameters, headers: headers).validate().responseJSON {
//        Alamofire.request("http://192.168.1.104:5000/sms", method: .post, parameters: parameters, headers: headers).validate().responseJSON {
            response in
            switch response.result {
            case .success:
                print ("Successful")
            case .failure(let error):
                print(error)
            }
        }
        
         audioPlayer?.stop()
    }
    
}
