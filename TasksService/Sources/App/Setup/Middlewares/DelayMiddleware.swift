//
//  DelayMiddleware.swift
//  Run
//

import Vapor
import HTTP

final class DelayMiddleware: Middleware {

    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let response = try next.respond(to: request)

        // Just to fake network latency
        usleep(500000)

        return response
    }
}
