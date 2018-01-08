//
//  ResponseMiddleware.swift
//  App
//

import Vapor
import HTTP

final class ResponseMiddleware: Middleware {

    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let response = try next.respond(to: request)

        if let bytes = response.body.bytes {
            let originJSON = try JSON(bytes: bytes)
            var finalJSON = JSON()

            try finalJSON.set("status", true)
            try finalJSON.set("value", originJSON)

            response.body = finalJSON.makeBody()
        }

        return response
    }
}
