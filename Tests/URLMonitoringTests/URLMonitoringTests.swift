import XCTest
@testable import URLMonitoring

final class URLMonitoringTests: XCTestCase {
    
    func test_monitorNotifyOnFileCreation() throws {
        let urlDirectory = testDirectory()
        var sut = try makeSUT(for: urlDirectory)
        let exp = expectation(description: "changeIsCalled")
        sut.onChange = { updatedURL in
            XCTAssertEqual(urlDirectory, updatedURL)
            exp.fulfill()
        }
        
        try sut.startMonitoring()
        
        let fileURL = urlDirectory.appendingPathComponent("someFile")
        try Data().write(to: fileURL)
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_monitorNotifyOnFileEditing() throws {
        let urlDirectory = testDirectory()
        let fileURL = urlDirectory.appendingPathComponent("someFile")
        try Data().write(to: fileURL)
        let sut = try URLMonitor(fileURL)
        let exp = expectation(description: "changeIsCalled")
        
        sut.onChange = { updatedURL in
            XCTAssertEqual(fileURL, updatedURL)
            exp.fulfill()
        }
        
        try sut.startMonitoring()
        try "AnyData".data(using: .utf8)!.write(to: fileURL, options: .atomic)
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_monitorNotifyOnFileDeletion() throws {
        let urlDirectory = testDirectory()
        let fileURL = urlDirectory.appendingPathComponent("someFile")
        try Data().write(to: fileURL)
        let sut = try URLMonitor(fileURL)
        let exp = expectation(description: "changeIsCalled")
        
        sut.onChange = { updatedURL in
            XCTAssertEqual(fileURL, updatedURL)
            exp.fulfill()
        }
        
        try sut.startMonitoring()
        try FileManager.default.removeItem(at: fileURL)
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_monitorCanNotStartTwice() throws {
        let urlDirectory = testDirectory()
        let sut = try makeSUT(for: urlDirectory)
        
        try sut.startMonitoring()
        
        XCTAssertThrowsError(try sut.startMonitoring(), "Monitor should not start twice")
    }
    
    func test_monitorCanStartAfterAStop() throws {
        let urlDirectory = testDirectory()
        let sut = try makeSUT(for: urlDirectory)
        
        try sut.startMonitoring()
        sut.stopMonitoring()
        
        XCTAssertThrowsError(try sut.startMonitoring())
    }
    
    func test_monitorDoesNotNotifyIfStopped() throws {
        let urlDirectory = testDirectory()
        let fileURL = urlDirectory.appendingPathComponent("someFile")
        try Data().write(to: fileURL)
        let sut = try URLMonitor(fileURL)
        let exp = expectation(description: "changeIsCalled")
        exp.isInverted = true
        
        sut.onChange = { updatedURL in
            XCTAssertEqual(fileURL, updatedURL)
            exp.fulfill()
        }
        
        try sut.startMonitoring()
        sut.stopMonitoring()
        
        try Data().write(to: fileURL)
        
        wait(for: [exp], timeout: 1)
    }
    
    private func makeSUT(for url: URL, file: StaticString = #filePath, line: UInt = #line) throws -> URLMonitoring {
        let sut = try URLMonitor(url)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
