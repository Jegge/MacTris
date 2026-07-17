//
//  URLSessionMocks.swift
//  MacTrisTests
//
//  Created by Sebastian Boettcher on 13.07.26.
//

import Foundation
@testable import MacTris

class MockURLSession: URLSessionProtocol {
    init(string: String) {
        result = .success((Data(string.utf8), URLResponse()))
    }

    init(error: Error) {
        result = .failure(error)
    }

    let result: Result<(Data, URLResponse), Error>

    func data(from url: URL) async throws -> (Data, URLResponse) {
        try result.get()
    }
}
