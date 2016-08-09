//
//  demoModel.swift
//  HealthyLife
//
//  Created by admin on 7/31/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//


import Foundation
import Firebase

class Demo {
    private var demoRef: FIRDatabaseReference!
    
    private var KeyDemo: String!
    
    private var NameDemo: String!
    private var IdDemo: String!
    
    
    
    var keyDemo: String {
        return KeyDemo
    }
    
    var nameDemo: String {
        return NameDemo
    }
    
    var idDemo: String {
        return IdDemo
    }
    
    
    init(key: String, dictionary: Dictionary<String, AnyObject>) {
        self.KeyDemo = key
        
        // Within the Joke, or Key, the following properties are children
        
        if let na = dictionary["name"] as? String {
            self.NameDemo = na
        }
        
        if let id = dictionary["id"] as? String {
            self.IdDemo = id
        }
        
        
        FIRDatabase.database().reference().child("demo_lib").child(self.KeyDemo)
    }
    
    
    
    
}

