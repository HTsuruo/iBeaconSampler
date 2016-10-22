//
//  SendBeacon.swift
//  iBeaconSampler
//
//  Created by Tsuru on H28/10/22.
//  Copyright © 平成28年 Tsuru. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class SendBeacon: NSObject, CBPeripheralManagerDelegate {

    // LocationManager.
    var myPheripheralManager:CBPeripheralManager!
    var uuidString = ""
    
    override init() {
        super.init()
        let userdefaults = UserDefaults.standard
        if let ud = userdefaults.object(forKey: "uuid") {
            self.uuidString = ud as! String
        } else {
            uuidString = NSUUID().uuidString
            UserDefaults.standard.set(uuidString, forKey: "uuid")
        }
        
        myPheripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        // iBeaconのUUID.
        let myProximityUUID = NSUUID(uuidString: uuidString)
        
        // iBeaconのIdentifier.
        let myIdentifier = "surechigai"
        
        // Major.
        let myMajor : CLBeaconMajorValue = 1
        
        // Minor.
        let myMinor : CLBeaconMinorValue = 2
        
        // BeaconRegionを定義.
        let myBeaconRegion = CLBeaconRegion(proximityUUID: myProximityUUID as! UUID, major: myMajor, minor: myMinor, identifier: myIdentifier)
        
//        let myBeaconRegion = CLBeaconRegion(proximityUUID: myProximityUUID as! UUID,  identifier: myIdentifier)
        
        // Advertisingのフォーマットを作成.
        let myBeaconPeripheralData = NSDictionary(dictionary: myBeaconRegion.peripheralData(withMeasuredPower: nil))
        
        // Advertisingを発信.
        myPheripheralManager.startAdvertising(myBeaconPeripheralData as? [String : AnyObject])
//        myPheripheralManager.startAdvertising(myBeaconPeripheralData as [NSObject : AnyObject] as [NSObject : AnyObject])
    }
}
