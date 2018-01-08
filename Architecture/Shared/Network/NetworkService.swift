//
//  NetworkService.swift
//  Architecture
//
//  Copyright © 2017 Oink oink. All rights reserved.
//

import Foundation

final class NetworkService {

    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL, session: URLSession = URLSession.shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func fetch<T: NetworkTask>(for task: T, failure: ((Error) -> Void)? = nil, success: @escaping (T.Response) -> Void) {
        guard let request = self.prepareRequest(for: task) else {
            failure?(NetworkError.requestPreparationFailed)

            return
        }

        self.session.dataTask(with: request) { [weak self] data, _, error in
            if let error = error {
                self?.executeOnMainIfNeeded { failure?(error) }
            } else if let data = data, let response = self?.parse(for: task, response: self?.prepareJSON(data: data)) {
                self?.executeOnMainIfNeeded { success(response) }
            } else {
                self?.executeOnMainIfNeeded { failure?(NetworkError.requestFailed) }
            }
        }.resume()
    }

    // MARK: - Request helpers
    private func prepareRequest<T: NetworkTask>(for task: T) -> URLRequest? {
        guard let endPointURL = URL(string: task.endPoint, relativeTo: self.baseURL) else { return nil }

        var urlRequest = URLRequest(url: endPointURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)

        urlRequest.allHTTPHeaderFields = ["content-type": "application/json"]
        urlRequest.httpMethod = task.method.rawValue
        urlRequest.httpBody = task.body

        return urlRequest
    }

    // MARK: - Response helpers
    private func prepareJSON(data: Data) -> JSON? {
        let json = try? JSONSerialization.jsonObject(with: data, options: [])

        return json as? JSON
    }

    private func parse<T: NetworkTask>(for task: T, response: JSON?) -> T.Response? {
        guard let response = response,
            let status = response["status"] as? Bool, status,
            let value = response["value"] else { return nil }

        return task.parse(value)
    }

    private func executeOnMainIfNeeded(_ block: @escaping () -> Void) {
        if Thread.current != Thread.main {
            DispatchQueue.main.async {
                block()
            }
        } else {
            block()
        }
    }
}
