//
//  CustomLabel.swift
//  Are We There Yet
//
//  Created by Josef Rönn on 2015-08-02.
//  Copyright © 2015 Josef Rönn. All rights reserved.
//

import Foundation

class CustomLabel:UILabel {
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder:aDecoder)
        
        self.font = UIFont(name: "Verdana", size: 20)
        self.numberOfLines = 0
        self.baselineAdjustment = .AlignCenters
        self.textAlignment  = NSTextAlignment.Center
        
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
    }
}