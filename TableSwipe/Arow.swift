//
//  Arow.swift
//  TableSwipe
//
//  Created by tady on 7/15/14.
//  Copyright (c) 2014 tady. All rights reserved.
//

import Foundation

struct FeatureVector: Printable {
    var vector: Dictionary<String, Double>
    let defaultValue: Double
    
    init(defaultValue: Double = 0.0) {
        self.vector = [:]
        self.defaultValue = defaultValue
    }
    
    init(vector: Dictionary<String, Double>, defaultValue: Double = 0.0) {
        self.defaultValue = defaultValue
        self.vector = vector
    }
    
    subscript(key: String) -> Double {
        get {
            if let value = self.vector[key] {
                return value
            } else {
                // self.vector[key] = self.defaultValue
                return self.defaultValue
            }
        }
        set(newValue) {
            self.vector[key] = newValue
        }
    }
    
    var description: String {
    return self.vector.description
    }
}

class Arow: Printable {
    
    let r: Double
    var means: FeatureVector
    var covariance: FeatureVector
    
    init(r: Double) {
        self.r = r
        self.means = FeatureVector(defaultValue: 0.0)
        self.covariance = FeatureVector(defaultValue: 1.0)
    }
    
    var description: String {
    return "Arow<r: \(r), means: \(self.means), covariance: \(self.covariance)>"
    }
    
    func margin(fv: FeatureVector) -> Double {
        var margin: Double = 0.0
        
        for (key, value) in fv.vector {
            margin += self.means[key] * value
        }
        
        return margin
    }
    
    func predict(fv: FeatureVector) -> Bool {
        return margin(fv) > 0
    }
    
    func update(fv: FeatureVector, label: Bool) -> Bool {
        let margin = self.margin(fv)
        let label_value: Double = label ? 1.0 : -1.0
        
        if label_value * margin >= 1 {
            return false
        }
        
        var confidence: Double = 0.0
        
        for (key, value) in fv.vector {
            confidence += self.covariance[key] * value * value
        }
        
        var beta = 1.0 / (confidence + self.r)
        var alpha = label_value * (1.0 - label_value * margin) * beta
        
        for (key, value) in fv.vector {
            var v = self.covariance[key] * value
            self.means[key] = self.means[key] + alpha * v
            self.covariance[key] = self.covariance[key] - beta * v * v
        }
        
        return true
    }
    
    func archiveData() -> Dictionary<String, AnyObject> {
        return [
            "means": self.means.vector,
            "covariance": self.covariance.vector,
            "r": self.r
        ]
    }

    func save() {
        let directory = NSHomeDirectory().stringByAppendingString("/Documents")
        let filePath = directory.stringByAppendingPathComponent("data.dat")
        println("filePath: \(filePath)")
        
        let saveSucceeded = NSKeyedArchiver.archiveRootObject(self.archiveData(), toFile: filePath)
        if saveSucceeded {
            println("Arow successfully saved.")
        } else {
            println("Arow NOT saved.")
        }
    }
    
}