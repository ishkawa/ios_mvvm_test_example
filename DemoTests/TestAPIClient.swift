//
//  TestAPIClient.swift
//  DemoTests
//
//  Created by Yosuke Ishikawa on 2019/01/14.
//  Copyright © 2019 Yosuke Ishikawa. All rights reserved.
//

import Foundation
import RxSwift

@testable import Demo

final class TestAPIClient: APIClient {
    private var stubs = [] as [(request: Any, response: Any)]
    
    func stub<Request: APIRequest>(request: Request, response: Single<Request.Response>) {
        stubs.append((request: request, response: response))
    }

    func sendRequest<Request: APIRequest>(_ request: Request) -> Single<Request.Response> {
        if let index = stubs.firstIndex(where: { ($0.request as? Request) == request }) {
            let stub = stubs.remove(at: index)
            return stub.response as! Single<Request.Response>
        } else {
            return Single.error(RxError.unknown)
        }
    }
}
