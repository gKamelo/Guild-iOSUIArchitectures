//
//  NetworkTask.swift
//  Architecture
//
//  Copyright © 2017 Oink oink. All rights reserved.
//

import Foundation

typealias JSON = [String: Any]

enum HTTPMethod: String {

    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
}

protocol NetworkTask {

    associatedtype Response

    var endPoint: String { get }
    var method: HTTPMethod { get }
    var body: Data? { get }

    func parse(_ data: Any) -> Response?
}

extension NetworkTask {

    var method: HTTPMethod { return .get }
    var body: Data? { return nil }

    func parse(_ data: Any) -> Bool? {
        return data as? Bool
    }
}
