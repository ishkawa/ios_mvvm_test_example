//
//  AppResolver.swift
//  Demo
//
//  Created by Yosuke Ishikawa on 2019/01/14.
//  Copyright © 2019 Yosuke Ishikawa. All rights reserved.
//

import Foundation
import DIKit

protocol AppResolver: Resolver {
    func provideAppResolver() -> AppResolver
    func provideAPIClient() -> APIClient
}

final class ConcreteAppResolver: AppResolver {
    private let apiClient = LocalAPIClient()
    
    func provideAppResolver() -> AppResolver {
        return self
    }
    
    func provideAPIClient() -> APIClient {
        return apiClient
    }
}
