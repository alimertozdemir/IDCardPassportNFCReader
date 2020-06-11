//
//  ViewController.swift
//  IDCardPassportNFCReader
//
//  Created by AliOzdem on 28.04.2020.
//  Copyright © 2020 AliMert. All rights reserved.
//

import UIKit
import CoreNFC

class ViewController: UIViewController {

    var nfcSession: NFCTagReaderSession?
    //let verify: [UInt8] = [0x00, 0x00, 0x00, 0x00]
    //let readBinary: [UInt8] = [0x00, 0x00, 0x00, 0x00]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //readCard()
    }
    
    private func readCard() {
        guard NFCTagReaderSession.readingAvailable else {
            let alertController = UIAlertController(
                title: "Scanning Not Supported",
                message: "This device doesn't support tag scanning.",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }

        nfcSession = NFCTagReaderSession(pollingOption: [.iso14443], delegate: self)
        nfcSession?.alertMessage = "Hold your iPhone near the item to learn more about it."
        nfcSession?.begin()
    }
    
}


extension ViewController: NFCTagReaderSessionDelegate {
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("tagReaderSessionDidBecomeActive -> Connected Tag: ", session.connectedTag.debugDescription)
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print("tagReaderSession -> error: ", error.localizedDescription)
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        print("tagReaderSession -> didDetect: ", tags.description)
        if tags.count > 1 {
                let retryInterval = DispatchTimeInterval.milliseconds(500)
                session.alertMessage = "More than 1 tag is detected, please remove all tags and try again."
                DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                    session.restartPolling()
                })
                return
            }

            let tag = tags.first!

            session.connect(to: tag) { (error) in
                if nil != error {
                    session.invalidate(errorMessage: error.debugDescription)
                    return
                }

                guard case .iso7816(let typeBTag) = tag else {
                    let retryInterval = DispatchTimeInterval.milliseconds(500)
                    session.alertMessage = "NFC type-B"
                    DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                        session.restartPolling()
                    })
                    return
                }


                // Verify
                let myAPDU = NFCISO7816APDU(instructionClass:0, instructionCode:0xB0, p1Parameter:0,
                p2Parameter:0, data: Data(), expectedResponseLength:16)
                typeBTag.sendCommand(apdu: myAPDU) { (response: Data, sw1: UInt8, sw2: UInt8, error: Error?) in
                    print("sw1=\(sw1)", "sw2=\(sw2)")
                    if let error = error {
                        debugPrint(error)
                        print("Application failure / Verify")
                        session.invalidate(errorMessage: "Application failure / Verify")
                        return
                    }
                    if !(sw1 == 0x90 && sw2 == 0) {
                        print("Application failure / Verify")
                        session.invalidate(errorMessage: "Application failure / Verify : sw1=\(sw1), sw2=\(sw2)")
                        return
                    }

                    // READ BINARY
                    
                    /*
                    let myAPDU2 = NFCISO7816APDU(instructionClass:0, instructionCode:0xB0, p1Parameter:0,
                    p2Parameter:0, data: Data(), expectedResponseLength:16)
                    typeBTag.sendCommand(apdu: myAPDU2) { (response: Data, sw1: UInt8, sw2: UInt8, error: Error?) in
                        print("sw1=\(sw1)", "sw2=\(sw2)")
                        if let error = error {
                          debugPrint(error)
                          print("Application failure / READ BINARY")
                          session.invalidate(errorMessage: "Application failure / READ BINARY")
                          return
                        }
                        if !(sw1 == 0x90 && sw2 == 0) {
                          print("Application failure / READ BINARY")
                          session.invalidate(errorMessage: "Application failure / READ BINARY : sw1=\(sw1), sw2=\(sw2)")
                          return
                        }
                        let resString = String(data: response, encoding: .ascii)!
                        print(resString)
                        session.alertMessage = "読み取りできました！\(resString)"

                        session.invalidate()
                    }
                    
                    */
                }

            }
        }

}




