//
//  CustomSearchBar.swift
//  Are We There Yet
//
//  Created by Josef Rönn on 2015-07-14.
//  Copyright © 2015 Josef Rönn. All rights reserved.
//

import Foundation
import UIKit

class CustomSearchBar:UISearchBar {
    
    var textField:UITextField!
    
    required init(coder aDecoder:NSCoder) {
        super.init(coder:aDecoder)
        textField = self.valueForKey("searchField") as? UITextField
        
        setTextFieldColors(UIColor.whiteColor(), backgroundColor:UIColor.clearColor(), posColor:UIColor.whiteColor())
        setBorders(1,borderColor:UIColor.whiteColor())
        setBarStyle(UIColor.clearColor(),barBgImage:UIImage())
        setStylizedPlaceholder("", textColor:UIColor.whiteColor())
        
        textField.font = UIFont.systemFontOfSize(18)
    }
    
    
    private func setTextFieldColors(textColor:UIColor,backgroundColor:UIColor,posColor:UIColor) {
        textField?.textColor = textColor
        textField?.backgroundColor = backgroundColor
        textField?.tintColor = posColor
    }
    
    
    private func setBorders(width:CGFloat, borderColor:UIColor) {
        textField?.layer.borderWidth = width
        textField?.layer.borderColor = borderColor.CGColor
        textField?.borderStyle = UITextBorderStyle.Line
    }
    
    private func setBarStyle (barColor:UIColor, barBgImage:UIImage) {
        self.barTintColor = barColor
        self.backgroundImage = barBgImage
    }
    
    private func setStylizedPlaceholder(placeholderText:String, textColor:UIColor) {
        let stylizedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSForegroundColorAttributeName:textColor])
        textField?.attributedPlaceholder = stylizedPlaceholder
    }
}