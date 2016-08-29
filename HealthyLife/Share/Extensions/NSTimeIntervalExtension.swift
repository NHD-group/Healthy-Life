//
//  NSTimeIntervalExtension.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 29/8/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import Foundation

extension NSTimeInterval {
    func readableDurationString() -> String {
        let hpd : NSTimeInterval = 24
        let mph : NSTimeInterval = 60
        let spm : NSTimeInterval = 60
        let sph = mph * spm
        
        if self > sph {
            return String(format:"%02d:%02d:%02d",Int((self / sph) % hpd) , Int((self / spm) % mph), Int(self % spm))
        }
        else {
            return String(format: "%02d:%02d", Int((self / spm) % mph), Int(self % spm))
        }
    }
}