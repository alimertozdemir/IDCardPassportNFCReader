//
//  NFCReadViewController.swift
//  IDCardPassportNFCReader
//
//  Created by AliOzdem on 9.06.2020.
//  Copyright © 2020 AliMert. All rights reserved.
//

import NFCPassportReader
import QKMRZScanner
import QKMRZParser

class NFCReadViewController: UIViewController {

    @IBOutlet weak var imgUserPhoto: UIImageView!
    @IBOutlet weak var tvUserInfo: UITextView!
    @IBOutlet weak var btnStartScan: UIButton!
    @IBOutlet weak var btnReadIdCard: UIButton!
    
    let passportReader = PassportReader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        resetUI()
    }
    
    @IBAction func startScan(_ sender: Any) {
        openScanner()
    }
    
    @IBAction func readCardAction(_ sender: Any) {
        
        let mrzData = ["I<TURA22P143571<17084322928<<<",
        "9002014M2108133TUR<<<<<<<<<<<2",
        "DOE<<JOHN<JIM<<<<<<<<<<<<<"]
        let mrzParser = QKMRZParser(ocrCorrection: true)
        let result = mrzParser.parse(mrzLines: mrzData)
        let passportModel = PassportModel(documentNumber: result!.documentNumber, birthDate: result!.birthDate!, expiryDate: result!.expiryDate!)
        readCard(passportModel)
        
    }
    
    private func readCard(_ passportModel: PassportModel) {
        let passportUtil = PassportUtil()
        passportUtil.passportNumber = passportModel.documentNumber
        passportUtil.dateOfBirth = passportModel.birthDate!.toString()
        passportUtil.expiryDate = passportModel.expiryDate!.toString()
        let mrzKey = passportUtil.getMRZKey()
        
        passportReader.readPassport(mrzKey: mrzKey, customDisplayMessage: { (displayMessage) in
            switch displayMessage {
                case .requestPresentPassport:
                    return "Hold your iPhone near an NFC enabled ID Card / Passport."
                case .successfulRead:
                    return "ID Card / Passport Read Succesfully."
                case .readingDataGroupProgress(let dataGroup, let progress):
                    let progressString = self.handleProgress(percentualProgress: progress)
                    return "Reading Data \(dataGroup) ...\n\(progressString)"
                default:
                    return nil
            }
        }, completed: { (passport, error) in
            if let passport = passport {
                // All good, we got a passport
                DispatchQueue.main.async {
                    passportUtil.passport = passport
                    var result = "NAME: \(passportUtil.passport?.firstName ?? "") \n"
                    result += "SURNAME: \(passportUtil.passport?.lastName ?? "") \n"
                    result += "Personal Number: \(passportUtil.passport?.personalNumber ?? "") \n"
                        
                    var gender = "N/A"
                    if passportUtil.passport?.gender == "F" {
                        gender = "FEMALE"
                    } else if passportUtil.passport?.gender == "M" {
                        gender = "MALE"
                    }
                    result += "Gender: \(gender) \n"
                    
                    if passportUtil.passport?.dateOfBirth == passportModel.birthDate?.toString() {
                        result += "Birth Date: \(passportModel.birthDate?.toString(format: "dd.MM.yyyy") ?? "") \n"
                    }
                    
                    if passportUtil.passport?.documentExpiryDate == passportModel.expiryDate?.toString() {
                        result += "Expire Date: \(passportModel.expiryDate?.toString(format: "dd.MM.yyyy") ?? "") \n"
                    }
                    
                    result += "Serial Number: \(passportUtil.passport?.documentNumber ?? "") \n"
                    result += "Nationality: \(passportUtil.passport?.nationality ?? "") \n"
                
                    var documentType = "Unknown"
                    if passportUtil.passport?.documentType == "P" {
                        documentType = "Passport"
                    } else if passportUtil.passport?.documentType == "I" {
                        documentType = "ID Card"
                    }
                        
                    result += "Doc Type: \(documentType) \n"
                    result += "Issuer Authority: \(passportUtil.passport?.issuingAuthority ?? "") \n"
                    
                    print("Completed: ", result)
                    
                    self.imgUserPhoto.isHidden = false
                    self.tvUserInfo.isHidden = false
                    self.imgUserPhoto.image = passportUtil.passport?.passportImage
                    self.tvUserInfo.text = result
                }
            } else {
                print("Error: ", error.debugDescription)
            }
        })
    }
    
    private func resetUI() {
        imgUserPhoto.isHidden = true
        tvUserInfo.isHidden = true
    }
    
    func handleProgress(percentualProgress: Int) -> String {
        let p = (percentualProgress/20)
        let full = String(repeating: "🟢 ", count: p)
        let empty = String(repeating: "⚪️ ", count: 5-p)
        return "\(full)\(empty)"
    }

}

extension NFCReadViewController: ProcessScanResult {
    
    func process(scanResult: QKMRZScanResult) {
        let passportModel = PassportModel(documentNumber: scanResult.documentNumber, birthDate: scanResult.birthDate!, expiryDate: scanResult.expiryDate!)
        readCard(passportModel)
    }
    
    func openScanner() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Scanner", bundle: nil)
        let scanVC: ScannerViewController = storyboard.instantiateViewController(withIdentifier:"PassportScanner") as! ScannerViewController
        scanVC.delegate = self
        self.navigationController?.pushViewController(scanVC, animated: false)
    }
}
