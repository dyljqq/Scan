//
//  Scan.swift
//  DbrDemo
//
//  Created by test on 2021/7/15.
//

import UIKit
import AVFoundation

class Scan: NSObject {
    
    let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
    
    let devivce = AVCaptureDevice.default(for: .video)
    
    lazy var session: AVCaptureSession = {
       let session = AVCaptureSession()
        session.sessionPreset = .high
        return session
    }()
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        previewLayer.videoGravity = .resize
        return previewLayer
    }()
    
    var callback: ((String) -> Void)?
    
    init(callback: @escaping (String) -> ()) {
        self.callback = callback

        super.init()
        setup()
    }
    
    func setup() {
        

        guard let input = try? AVCaptureDeviceInput(device: devivce!) else {
            print("error...")
            return
        }
        
        let output = AVCaptureMetadataOutput()
        previewLayer.session = session
        
        if self.session.canAddInput(input) {
            self.session.addInput(input)
        }
        
        if self.session.canAddOutput(output) {
            self.session.addOutput(output)
            
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = [
                .ean8,
                .ean13,
                .code128,
                .qr
            ]
        }
        
    }
    
    func start(view: UIView) {
        DispatchQueue.global().async {
            self.session.startRunning()
            DispatchQueue.main.async {
                let flag = view.layer.sublayers?.contains(self.previewLayer)
                if flag == nil {
                    self.previewLayer.frame = view.bounds
                    view.layer.insertSublayer(self.previewLayer, at: 0)
                }
            }
        }
    }
    
    func stop() {
        self.session.stopRunning()
    }
    
    
}

extension Scan: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let result = obj.stringValue else {
            return
        }
        callback?(result)
        self.stop()
    }
    
}
