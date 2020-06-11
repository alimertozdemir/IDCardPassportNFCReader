//
//  PassportModel.swift
//  IDCardPassportNFCReader
//
//  Created by AliOzdem on 10.06.2020.
//  Copyright © 2020 AliMert. All rights reserved.
//

import Foundation
import UIKit

struct PassportModel {
    
    var documentImage: UIImage = UIImage()
    var documentType: String = ""
    var countryCode: String = ""
    var surnames: String = ""
    var givenNames: String = ""
    var documentNumber: String = ""
    var nationality: String = ""
    var birthDate: Date? = Date()
    var sex: String = ""
    var expiryDate: Date? = Date()
    var personalNumber: String = ""
    
    init(documentNumber: String, birthDate: Date, expiryDate: Date) {
        self.documentNumber = documentNumber
        self.birthDate = birthDate
        self.expiryDate = expiryDate
    }
    
}
