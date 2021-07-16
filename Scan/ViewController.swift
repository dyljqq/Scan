//
//  ViewController.swift
//  DbrDemo
//
//  Created by test on 2021/7/15.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var scanImageView: UIImageView!
    
    let scan = Scan(callback: { result in
        print("输出结果: \(result)")
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        scan.start(view: scanImageView)
    }


}

