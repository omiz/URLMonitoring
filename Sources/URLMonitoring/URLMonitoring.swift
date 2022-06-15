//
//  URLMonitoring.swift
//  
//
//  Created by Omar Allaham on 6/13/22.
//

import Foundation

public protocol URLMonitoring {
    
    var onChange: ((URL) -> Void)? { get set }
    
    func startMonitoring() throws
    func stopMonitoring()
}
