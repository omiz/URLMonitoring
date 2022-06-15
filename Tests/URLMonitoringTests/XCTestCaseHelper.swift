//
//  XCTestCaseHelper.swift
//  
//
//  Created by Omar Allaham on 6/15/22.
//

import XCTest

extension XCTestCase {
    
    func testDirectory() -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        
        addTeardownBlock {
            try! FileManager.default.removeItem(atPath: url.path)
        }
        
        return url
    }
}
