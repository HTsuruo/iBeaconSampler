import Foundation
import CoreLocation

class ReceiveBeacon: NSObject, CLLocationManagerDelegate {
    
    var myLocationManager:CLLocationManager!
    var myBeaconRegion:CLBeaconRegion!
    var myIds: NSMutableArray!
    var myUuids: NSMutableArray!
    var beaconRegionArray = [CLBeaconRegion]()
    
    static let shard = ReceiveBeacon()
    
    let UUIDList = [
        "9EDFA660-204E-4066-8644-A432AE2B6ECE",
        ]
    
    override init() {
        
        super.init()
        
        print("init")
        
        // ロケーションマネージャの作成.
        myLocationManager = CLLocationManager()
        
        // デリゲートを自身に設定.
        myLocationManager.delegate = self
        
        // セキュリティ認証のステータスを取得
        let status = CLLocationManager.authorizationStatus()
        
        // 取得精度の設定.
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // 取得頻度の設定.(1mごとに位置情報取得)
        myLocationManager.distanceFilter = 1
        
        // まだ認証が得られていない場合は、認証ダイアログを表示
        if(status != CLAuthorizationStatus.authorizedAlways) {
            print("CLAuthorizedStatus: \(status)")
            
            // まだ承認が得られていない場合は、認証ダイアログを表示.
            myLocationManager.requestAlwaysAuthorization()
        }
        
        for i in 0 ..< UUIDList.count {
            
            // BeaconのUUIDを設定.
            let uuid:NSUUID! = NSUUID(uuidString: "\(UUIDList[i].lowercased())")
            
            // BeaconのIfentifierを設定.
            let identifierStr:String = "akabeacon" + i.description
            
            // リージョンを作成.
            myBeaconRegion = CLBeaconRegion(proximityUUID: uuid as UUID, major: CLBeaconMajorValue(1), minor: CLBeaconMinorValue(1), identifier: identifierStr)
            
            // ディスプレイがOffでもイベントが通知されるように設定(trueにするとディスプレイがOnの時だけ反応).
            myBeaconRegion.notifyEntryStateOnDisplay = false
            
            // 入域通知の設定.
            myBeaconRegion.notifyOnEntry = true
            
            // 退域通知の設定.
            myBeaconRegion.notifyOnExit = true
            
            beaconRegionArray.append(myBeaconRegion)
            
            myLocationManager.startMonitoring(for: myBeaconRegion)
        }
        
        // 配列をリセット
        myIds = NSMutableArray()
        myUuids = NSMutableArray()
    }
    
    /*
     (Delegate) 認証のステータスがかわったら呼び出される.
     */
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        print("didChangeAuthorizationStatus");
        
        // 認証のステータスをログで表示
        var statusStr = "";
        switch (status) {
        case .notDetermined:
            statusStr = "NotDetermined"
        case .restricted:
            statusStr = "Restricted"
        case .denied:
            statusStr = "Denied"
        case .authorizedAlways:
            statusStr = "AuthorizedAlways"
        case .authorizedWhenInUse:
            statusStr = "AuthorizedWhenInUse"
        }
        print(" CLAuthorizationStatus: \(statusStr)")
        
        for region in beaconRegionArray {
            manager.startMonitoring(for: region)
        }
    }
    
    /*
     STEP2(Delegate): LocationManagerがモニタリングを開始したというイベントを受け取る.
     */
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        
        print("didStartMonitoringForRegion");
        
        // STEP3: この時点でビーコンがすでにRegion内に入っている可能性があるので、その問い合わせを行う
        // (Delegate didDetermineStateが呼ばれる: STEP4)
        manager.requestState(for: region);
    }
    
    /*
     STEP4(Delegate): 現在リージョン内にいるかどうかの通知を受け取る.
     */
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        print("locationManager: didDetermineState \(state)")
        
        switch (state) {
            
        case .inside: // リージョン内にいる
            print("CLRegionStateInside:");
            
            // STEP5: すでに入っている場合は、そのままRangingをスタートさせる
            // (Delegate didRangeBeacons: STEP6)
            manager.startRangingBeacons(in: region as! CLBeaconRegion)
            break;
            
        case .outside:
            print("CLRegionStateOutside:")
            // 外にいる、またはUknownの場合はdidEnterRegionが適切な範囲内に入った時に呼ばれるため処理なし。
            break;
            
        case .unknown:
            print("CLRegionStateUnknown:")
        // 外にいる、またはUknownの場合はdidEnterRegionが適切な範囲内に入った時に呼ばれるため処理なし。
        default:
            
            break;
            
        }
    }
    
    /*
     STEP6(Delegate): ビーコンがリージョン内に入り、その中のビーコンをNSArrayで渡される.
     */
    private func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        
        // 配列をリセット
        myIds = NSMutableArray()
        myUuids = NSMutableArray()
        
        // 範囲内で検知されたビーコンはこのbeaconsにCLBeaconオブジェクトとして格納される
        // rangingが開始されると１秒毎に呼ばれるため、beaconがある場合のみ処理をするようにすること.
        if(beacons.count > 0){
            
            // STEP7: 発見したBeaconの数だけLoopをまわす
            for i in 0 ..< beacons.count {
                
                let beacon = beacons[i] as! CLBeacon
                
                let beaconUUID = beacon.proximityUUID;
                let minorID = beacon.minor;
                let majorID = beacon.major;
                let rssi = beacon.rssi;
                
                print("UUID: \(beaconUUID.uuidString)");
                print("minorID: \(minorID)");
                print("majorID: \(majorID)");
                print("RSSI: \(rssi)");
                
                var proximity = ""
                
                switch (beacon.proximity) {
                    
                case CLProximity.unknown :
                    print("Proximity: Unknown");
                    proximity = "Unknown"
                    break
                    
                case CLProximity.far:
                    print("Proximity: Far");
                    proximity = "Far"
                    break
                    
                case CLProximity.near:
                    print("Proximity: Near");
                    proximity = "Near"
                    break
                    
                case CLProximity.immediate:
                    print("Proximity: Immediate");
                    proximity = "Immediate"
                    break
                }
                
                let myBeaconId = "MajorId: \(majorID) MinorId: \(minorID)  UUID:\(beaconUUID) Proximity:\(proximity)"
                myIds.add(myBeaconId)
                myUuids.add(beaconUUID.uuidString)
            }
        }
    }
    
    
    /*
     (Delegate) リージョン内に入ったというイベントを受け取る.
     */
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("didEnterRegion");
        
        // Rangingを始める
        manager.startRangingBeacons(in: region as! CLBeaconRegion)
        
    }
    
    /*
     (Delegate) リージョンから出たというイベントを受け取る.
     */
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        NSLog("didExitRegion");
        
        // Rangingを停止する
        manager.stopRangingBeacons(in: region as! CLBeaconRegion)
    }
    
}
