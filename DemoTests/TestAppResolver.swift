//
//  TestAppResolver.swift
//  DemoTests
//
//  Created by Yosuke Ishikawa on 2019/01/14.
//  Copyright © 2019 Yosuke Ishikawa. All rights reserved.
//

import Foundation
import DIKit

@testable import Demo

final class TestAppResolver: AppResolver {
    let apiClient = TestAPIClient()
    
    func provideAppResolver() -> AppResolver {
        return self
    }
    
    func provideAPIClient() -> APIClient {
        return apiClient
    }
}
