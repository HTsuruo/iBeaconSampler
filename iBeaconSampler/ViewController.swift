//
//  ViewController.swift
//  iBeaconSampler
//
//  Created by Tsuru on H28/10/22.
//  Copyright © 平成28年 Tsuru. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ReceiveBeacon()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onClickStartBtn(_ sender: UIButton) {
        SendBeacon()
    }
}

