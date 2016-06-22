//
//  ViewController.swift
//  LytroExifier
//
//  Created by temoki on 2016/06/19.
//  Copyright © 2016 temoki.com. All rights reserved.
//

import Cocoa
import SQLite

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    // MARK:- Outlet members
    @IBOutlet var lytroLibTextField: NSTextField!
    @IBOutlet var lytroLibApplyButton: NSButton!
    @IBOutlet var imagesDirTextField: NSTextField!
    @IBOutlet var imagesDirApplyButton: NSButton!
    @IBOutlet var tableView: NSTableView!

    // MARK:- Properties
    private var metaItems = [LytroMetaItem]()
    private var imageFiles = [String: LytroExportedImageFile]()
    private let imageFileIdentifier = "image_file"
    
    
    // MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Table View
        self.tableView.setDelegate(self)
        self.tableView.setDataSource(self)

        let column = NSTableColumn(identifier: self.imageFileIdentifier)
        column.title = column.identifier
        self.tableView.addTableColumn(column)

        for key in LytroMetaItem.Keys {
            let column = NSTableColumn(identifier: key.rawValue)
            column.title = key.rawValue
            self.tableView.addTableColumn(column)
        }
    }

    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    // MARK: - NSTableViewDataSource
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.metaItems.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        if let identifier = tableColumn?.identifier {
            if identifier == self.imageFileIdentifier {
                if let name = self.metaItems[row][.Name] as? String {
                    return self.imageFiles[name]?.nameWithExt
                }
            } else {
                return self.metaItems[row][identifier]
            }
        }
        return nil
    }
    
    func tableView(tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
    }
    
    
    // MARK: - NSTableViewDelegate
    
    func tableViewSelectionDidChange(notification: NSNotification) {
    }
    
    
    // MARK: - Action

    @IBAction func lytroLibApplyAction(sender: NSButton) {
        let fileManager = NSFileManager.defaultManager()

        self.metaItems.removeAll()
        
        let libPath = self.lytroLibTextField.stringValue as NSString
        print(libPath)
        guard libPath.pathExtension.lowercaseString == "lytrolibrary" else {
            return
        }
        
        let dbName = "lytrolibrary.db"
        let srcDbPath = libPath.stringByAppendingPathComponent(dbName)
        guard fileManager.fileExistsAtPath(srcDbPath) else {
            return
        }
        
        let toDbPath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(dbName)
        do {
            if fileManager.fileExistsAtPath(toDbPath) {
                try fileManager.removeItemAtPath(toDbPath)
            }
            try fileManager.copyItemAtPath(srcDbPath, toPath: toDbPath)
        } catch let error as NSError {
            print("Copy Error: \(error)")
            return
        }
       
        guard fileManager.fileExistsAtPath(toDbPath) else {
            return
        }

        do {
            let db = try Connection(toDbPath)
            print("Connection OK")
            
            var query = LytroMetaItem.Keys.reduce("") { (value1: String, value2: LytroMetaItem.Key) in
                value1.isEmpty ? "SELECT " + value2.rawValue : value1 + ", " + value2.rawValue
            }
            query += " FROM picture INNER JOIN picture_metadata ON picture.id == picture_metadata.id"
            for dbRow in try db.prepare(query) {
                print(dbRow)
                
                let item = LytroMetaItem()
                item[.Name] = dbRow[0] as? String
                item[.CaptureDate] = dbRow[1] as? String
                item[.ShutterSpeed] = dbRow[3] as? Double
                item[.FNumber] = dbRow[5] as? Double
                item[.Exposure] = dbRow[6] as? Double
                item[.FocalLength] = dbRow[7] as? Double
                
                if let iso = dbRow[4] as? Int64 {
                    item[.ISO] = Int(iso)
                }
                
                if let cameraModel = dbRow[2] as? String {
                    let modelName: String
                    switch cameraModel {
                    case "1":
                        modelName = "LYTRO IMMERGE"
                    case "2":
                        modelName = "LYTRO ILLUM"
                    default:
                        modelName = ""
                    }
                    item[.CameraModel] = modelName
                }

                self.metaItems.append(item)
            }
            
        } catch let error as NSError {
            print("Connection Error: \(error)")
            return
        }
        
        self.tableView.reloadData()
    }

    @IBAction func exportedDirApplyAction(sender: NSButton) {
        let fileManager = NSFileManager.defaultManager()
        
        self.metaItems.removeAll()
        
        let imagesDirPath = self.imagesDirTextField.stringValue
        print(imagesDirPath)
        
        var isDirectory: ObjCBool = false
        guard fileManager.fileExistsAtPath(imagesDirPath, isDirectory: &isDirectory) else {
            return
        }
        guard isDirectory.boolValue else {
            return
        }
        
        guard let paths = try? fileManager.contentsOfDirectoryAtPath(imagesDirPath) else {
            return
        }
        
        for path in paths {
            if let imageFile = LytroExportedImageFile(path: path) {
                self.imageFiles[imageFile.nameWithoutExt] = imageFile
            }
        }
        
        self.tableView.reloadData()
    }

}
