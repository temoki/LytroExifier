//
//  LytroExportedImageFile.swift
//  LytroExifier
//
//  Created by temoki on 2016/06/22.
//  Copyright © 2016 temoki.com. All rights reserved.
//

import Foundation

class LytroExportedImageFile {
    
    let path: String
    
    init?(path: String) {
        let pathExtension = (path as NSString).pathExtension.lowercaseString
        switch pathExtension {
        case "jpg", "jpeg", "tif", "tiff":
            self.path = path
        default:
            return nil
        }
    }
    
    var nameWithExt: String {
        get {
            return (self.path as NSString).lastPathComponent
        }
    }
    
    var nameWithoutExt: String {
        get {
            return (self.nameWithExt as NSString).stringByDeletingPathExtension
        }
    }
    
    var ext: String {
        get {
            return (self.path as NSString).pathExtension
        }
    }
    
}
