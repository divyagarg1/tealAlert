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
class CofigViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var time: UIPickerView!
    
    @IBOutlet var timer: UISlider!
    @IBOutlet var name: UITextField!
    @IBOutlet var alertTime: UITextField!
    @IBOutlet var contactsNum: UITextField!
    @IBOutlet var contactName: UITextField!
   
    var savedConfig:Config!
    
    @IBOutlet var saveConfigButton: UIButton!
    
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var editConfigButton: UIButton!
    
    // Use the context from AppDelegate to store the config
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    //Display elements
    
    @IBOutlet var contactNameLabel: UILabel!
    
    @IBOutlet var contactNumLabel: UILabel!
    
    @IBOutlet var alertLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    let MIN_THRESHOLD = 9
    
    
    func initConfig() {
        nameLabel.text = savedConfig.name ?? ""
        contactNameLabel.text = savedConfig.contact_name ?? ""
        contactNumLabel.text = savedConfig.contact_phone ?? ""
        alertLabel.text = savedConfig.alert_time ?? ""
        
        name.text = savedConfig.name ?? ""
        contactName.text = savedConfig.contact_name ?? ""
        contactsNum.text = savedConfig.contact_phone ?? ""
        alertTime.text = savedConfig.alert_time ?? ""

    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.fetchConfigFromCoreData()
        self.changeView()
    }
    
    
    
    
    @IBAction func saveConfig(_ sender: UIButton) {
        alertTime.resignFirstResponder()
        if name.text != nil {
            let context =  appDelegate.persistentContainer.viewContext
            //Save or update
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Config")
            let predicate = NSPredicate(format: "id=%@", "1")
            fetchRequest.predicate = predicate
            
            do {
                let results = try context.fetch(fetchRequest)
                
                if(results.count != 0){
                    let config = results.last as! Config
                    config.name = name.text
                    config.contact_name = contactName.text
                    config.contact_phone = contactsNum.text
                    config.alert_time = alertTime.text
                    do {
                        try context.save()
                    } catch let error as NSError {
                        print ("Error first demande insertion \(error)")
                    }
                    
                } else if (results.count == 0) {
                    
                    let config = NSEntityDescription.insertNewObject(forEntityName: "Config", into: context) as! Config
                    
                    config.id = 1
                    config.name = name.text
                    config.contact_name = contactName.text
                    config.contact_phone = contactsNum.text
                    config.alert_time = alertTime.text
                    
                    context.insert(config)
                    
                    do {
                        try context.save()
                    } catch let error as NSError {
                        print ("Error first demande insertion \(error)")
                    }
                }
            } catch {
                let fetchError = error as NSError
                print(fetchError)
            }
            presentConfirmationAlert()
            fetchConfigFromCoreData()
            changeView()
        }
        
    }
    
    func presentConfirmationAlert() {
        let alert = UIAlertController(title: "Saved", message: "Your Configuration is Saved.", preferredStyle: UIAlertControllerStyle.alert)
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
                initConfig()
            }
        } catch {
            print("Fetching Config from Core Data failed :( ")
        }
    }
    
    
    @IBAction func editConfig(_ sender: Any) {
        for label in [nameLabel, alertLabel, contactNumLabel, contactNameLabel] {
            label?.isHidden = true
        }
        
        for textField in [name, contactsNum, contactName, alertTime] {
            textField?.isHidden = false
        }
        editConfigButton.isHidden = true
        saveConfigButton.isHidden = false
        cancelButton.isHidden = false
    }
    
    func changeView() {
        for label in [nameLabel, alertLabel, contactNumLabel, contactNameLabel] {
            label?.isHidden = false
        }
        
        for textField in [name, contactsNum, contactName, alertTime] {
            textField?.isHidden = true
        }
        saveConfigButton.isHidden = true
        editConfigButton.isHidden = false
        cancelButton.isHidden = true
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        changeView()
    }
}
