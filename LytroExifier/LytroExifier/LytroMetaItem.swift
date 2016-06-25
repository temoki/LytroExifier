//
//  LytroMetaItem.swift
//  LytroExifier
//
//  Created by temoki on 2016/06/22.
//  Copyright © 2016 temoki.com. All rights reserved.
//

import Foundation

class LytroMetaItem {
    
    private var data = [String: AnyObject]()

    enum Key: String {
        case Name         = "name"            // String -
        case CaptureDate  = "capture_date"    // String kCGImagePropertyExifDateTimeOriginal/Digitized
        case CameraModel  = "camera_model"    // String kCGImagePropertyExifLensModel
        case CameraMode   = "camera_mode"     // String kCGImagePropertyExifExposureProgram
        case ShutterSpeed = "shutter_speed"   // Double kCGImagePropertyExifShutterSpeedValue
        case ISO          = "iso"             // Int    kCGImagePropertyExifISOSpeed
        case FNumber      = "fnumber"         // Double kCGImagePropertyExifFNumber
        case Exposure     = "exposure"        // Double kCGImagePropertyExifExposureBiasValue
        case FocalLength  = "focal_length"    // Double kCGImagePropertyExifFocalLength
    }
    
    static let Keys: [Key] = [.Name, .CaptureDate, .CameraModel, .CameraMode, .ShutterSpeed,
                              .ISO, .FNumber, .Exposure, .FocalLength]
    
    subscript(key: Key) -> AnyObject? {
        get { return self.data[key.rawValue] }
        set { self.data[key.rawValue] = newValue }
    }
    
    subscript(key: String) -> AnyObject? {
        get { return self.data[key] }
        set { self.data[key] = newValue }
    }
    
    func exifValue(key: Key) -> AnyObject? {
        switch key {
        case .CaptureDate:
            return self.captureDateForExif()
        case .CameraModel:
            return self.cameraModelForExif()
        case .CameraMode:
            return self.cameraModeForExif()
        case .ShutterSpeed:
            return self.shutterSpeedForExif()
        default:
            return self[key]
        }
    }
    
    private func captureDateForExif() -> String? {
        guard let captureDateStr = self[.CaptureDate] as? String else {
            return nil
        }
        
        let lytroDateFormatter = NSDateFormatter()
        lytroDateFormatter.timeZone = NSTimeZone(name: "GMT")
        lytroDateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        lytroDateFormatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        lytroDateFormatter.dateFormat = "yyyy-MMM-dd HH:mm:ss.SSSSSS"
        guard let captureDate = lytroDateFormatter.dateFromString(captureDateStr) else {
            return nil
        }
        
        let exifDateFormatter = NSDateFormatter()
        exifDateFormatter.timeZone = NSTimeZone.systemTimeZone()
        exifDateFormatter.locale = NSLocale.systemLocale()
        exifDateFormatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        exifDateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        let exifDateStr = exifDateFormatter.stringFromDate(captureDate)
        print("\(captureDateStr) => \(captureDate) => \(exifDateStr)")
        return exifDateStr
    }
    
    private func cameraModelForExif() -> String? {
        if let cameraModel = self[.CameraModel] as? String {
            switch cameraModel {
            case "1":
                return "LYTRO IMMERGE"
            case "2":
                return "LYTRO ILLUM"
            default:
                return nil
            }
        }
        return nil
    }
    
    private func cameraModeForExif() -> Int? {
        if let cameraMode = self[.CameraMode] as? Int {
            // [Lytro] 3: Program, 4: ISO, 5: ShutterSpeed
            // [EXIF ] 1: Manual, 2: Program, 3: Aperture, 4: ShutterSpeed
            switch cameraMode {
            case 3: // Program
                return 2 // Program
            case 4: // ISO
                return 3 // Aperture
            case 5: // Shutter Speed
                return 4 // Shutter Speed
            default: // Unknown
                return 0 // Undefined
            }
        }
        return nil
    }
    
    private func shutterSpeedForExif() -> Double? {
        if let shutterSpeed = self[.ShutterSpeed] as? Double {
            return -1.0 * log2(shutterSpeed) // to Apex Value
        }
        return nil
    }
    
}
