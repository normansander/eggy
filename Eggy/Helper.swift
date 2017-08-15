//
//  Helper.swift
//  Eggy
//
//  Created by Norman Sander on 24.07.15.
//  Copyright (c) 2015 Norman Sander. All rights reserved.
//

import Foundation
import UIKit

class Helper {
    class func printFonts() {
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            print("------------------------------")
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName )
            print("Font Names = [\(names)]")
        }
    }
}
