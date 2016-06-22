//
//  LytroMetaItem.swift
//  LytroExifier
//
//  Created by temoki on 2016/06/22.
//  Copyright © 2016 temoki.com. All rights reserved.
//

import Foundation

class LytroMetaItem {
    
    enum Key: String {
        case Name         = "name"            // String
        case CaptureDate  = "capture_date"    // String
        case CameraModel  = "camera_model"    // String
        case ShutterSpeed = "shutter_speed"   // Double
        case ISO          = "iso"             // Int
        case FNumber      = "fnumber"         // Double
        case Exposure     = "exposure"        // Double
        case FocalLength  = "focal_length"    // Double
    }
    
    static let Keys: [Key] = [.Name, .CaptureDate, .CameraModel, .ShutterSpeed,
                              .ISO, .FNumber, .Exposure, .FocalLength]
    
    subscript(key: Key) -> AnyObject? {
        get { return self.data[key.rawValue] }
        set { self.data[key.rawValue] = newValue }
    }
    
    subscript(key: String) -> AnyObject? {
        get { return self.data[key] }
        set { self.data[key] = newValue }
    }
    
    private var data = [String: AnyObject]()
}
