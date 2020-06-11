//
//  ScannerViewController.swift
//  IDCardPassportNFCReader
//
//  Created by AliOzdem on 9.06.2020.
//  Copyright © 2020 AliMert. All rights reserved.
//
import QKMRZScanner

protocol ProcessScanResult {
    func process(scanResult: QKMRZScanResult)
}

class ScannerViewController: UIViewController, QKMRZScannerViewDelegate {
    
    var delegate: ProcessScanResult?
    
    @IBOutlet weak var mrzScannerView: QKMRZScannerView!

   override func viewDidLoad() {
        super.viewDidLoad()
        mrzScannerView.tintColor = UIColor.green
        mrzScannerView.delegate = self
        mrzScannerView.vibrateOnResult = true
   }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mrzScannerView.startScanning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mrzScannerView.stopScanning()
    }

   func mrzScannerView(_ mrzScannerView: QKMRZScannerView, didFind scanResult: QKMRZScanResult) {
        mrzScannerView.stopScanning()
        print("Scan Result: \(scanResult.givenNames)")
        delegate?.process(scanResult: scanResult)
        self.navigationController?.popViewController(animated: false)
   }
}
