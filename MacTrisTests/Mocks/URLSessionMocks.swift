//
//  URLSessionMocks.swift
//  MacTrisTests
//
//  Created by Sebastian Boettcher on 13.07.26.
//

import Foundation
@testable import MacTris

class MockURLSession: URLSessionProtocol {
    convenience init(string: String) {
        self.init(statusCode: 200, string: string)
    }

    init(statusCode: Int, string: String) {
        let url = URL(string: "https://example.com") ?? URL(fileURLWithPath: "/")
        if let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil) {
            result = .success((Data(string.utf8), response))
        } else {
            result = .failure(URLError(.badURL))
        }
    }

    init(error: Error) {
        result = .failure(error)
    }

    let result: Result<(Data, URLResponse), Error>

    func data(from url: URL) async throws -> (Data, URLResponse) {
        try result.get()
    }
}
