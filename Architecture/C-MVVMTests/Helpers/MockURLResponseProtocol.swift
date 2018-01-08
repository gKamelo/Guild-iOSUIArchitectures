//
//  MockURLResponseProtocol.swift
//  C-MVVMTests
//
//  Copyright © 2017 Oink oink. All rights reserved.
//

import Foundation

class MockURLResponseProtocol: URLProtocol {

    var mockData: Data? {
        return nil
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return request.url?.scheme == "mock"
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let url = self.request.url,
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["content-type": "application/json; charset=utf-8"]) else { return }

        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

        if let data = self.mockData {
            self.client?.urlProtocol(self, didLoad: data)
        }

        self.client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() { }
}

extension MockURLResponseProtocol {

    func loadData(from fileName: String) -> Data? {
        guard let filePath = Bundle(for: type(of: self)).path(forResource: fileName, ofType: "json"),
            let data = NSData(contentsOfFile: filePath) as Data? else { return nil }

        return data
    }
}
