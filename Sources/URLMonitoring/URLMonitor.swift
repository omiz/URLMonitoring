//
//  URLMonitor.swift
//  
//
//  Created by Omar Allaham on 6/13/22.
//

import Foundation

public final class URLMonitor {
    
    public let url: URL
    public var onChange: ((URL) -> Void)?

    private var monitorSource: DispatchSourceFileSystemObject?
    private let monitorQueue = DispatchQueue(label: "URLDirectoryMonitor", attributes: .concurrent)
    
    public init(_ directory: URL, onChange: ((URL) -> Void)? = nil) throws {

        
        self.url = directory
        self.onChange = onChange
    }
}

extension URLMonitor: URLMonitoring {
    
    public func startMonitoring() throws {
        
        guard monitorSource == nil else {
            throw URLMonitoringError.monitorAlreadyRunning
        }
        
        let fileDescriptor = open(url.path, O_EVTONLY)
        
        monitorSource = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: .all,
            queue: monitorQueue
        )
        
        monitorSource?.setEventHandler { [weak self] in
            guard let self = self else { return }
            self.onChange?(self.url)
        }
        
        monitorSource?.setCancelHandler(qos: .background, flags: .barrier, handler: { [weak self] in
            guard let self = self else { return }
            close(fileDescriptor)
            self.monitorSource = nil
        })
        
        monitorSource?.resume()
    }
    
    public func stopMonitoring() {
        DispatchQueue.global(qos: .background).sync {
            monitorSource?.cancel()
        }
    }
}
