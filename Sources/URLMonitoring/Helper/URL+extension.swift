//
//  URL+extension.swift
//  
//
//  Created by Omar Allaham on 6/15/22.
//

import Foundation

extension URL {
    var isDirectoryURL: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
