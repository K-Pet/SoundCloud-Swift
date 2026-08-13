//
//  File.swift
//  
//
//  Created by Ryan Forsyth on 2023-08-14.
//

import Foundation

public extension SoundCloud {
    enum Error: Swift.Error {
        case loggingIn
        case cancelledLogin
        case userNotAuthorized
        case network(StatusCode)
        /// The response body didn't match the expected model.
        ///
        /// Carries the underlying `DecodingError` and the raw body, so a schema change
        /// on SoundCloud's side is diagnosable from a log instead of opaque.
        case decoding(underlying: Swift.Error, responseBody: String?)
        case invalidURL
        case noInternet
        case refreshingExpiredAuthTokens
        case tooManyRequests
    }
}
