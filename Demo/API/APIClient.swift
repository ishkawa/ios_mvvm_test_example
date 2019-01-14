//
//  APIClient.swift
//  Demo
//
//  Created by Yosuke Ishikawa on 2019/01/14.
//  Copyright © 2019 Yosuke Ishikawa. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol APIRequest: Equatable {
    associatedtype Response
}

protocol APIClient {
    func sendRequest<Request: APIRequest>(_ request: Request) -> Single<Request.Response>
}

final class LocalAPIClient: APIClient {
    private let repositories: [Repository] = [
        Repository(id: 1, name: "mxcl/swift-sh", description: "Easily import third-party dependencies in your Swift scripts", isStarred: false),
        Repository(id: 2, name: "yagiz/Bagel", description: "a little native network debugging tool for iOS", isStarred: false),
        Repository(id: 3, name: "IdeasOnCanvas/Aiolos", description: "A floating panel for your iOS Apps", isStarred: false),
        Repository(id: 4, name: "iina/iina", description: "The modern video player for macOS.", isStarred: false),
        Repository(id: 5, name: "yichengchen/clashX", description: "A rule based custom proxy with GUI for Mac base on clash.", isStarred: false),
        Repository(id: 6, name: "rwbutler/Connectivity", description: "Makes Internet connectivity detection more robust by detecting Wi-Fi networks without Internet access.", isStarred: false),
        Repository(id: 7, name: "mxcl/PromiseKit", description: "Promises for Swift & ObjC", isStarred: false),
        Repository(id: 8, name: "rsrbk/LayoutLoopHunter", description: "Runtime-based setup for tracking autolayout feedback loops", isStarred: false),
        Repository(id: 9, name: "airbnb/MagazineLayout", description: "A collection view layout capable of laying out views in vertically scrolling grids and lists.", isStarred: false),
        Repository(id: 10, name: "SnapKit/SnapKit", description: "A Swift Autolayout DSL for iOS & OS X", isStarred: false),
        Repository(id: 11, name: "ReactiveX/RxSwift", description: "Reactive Programming in Swift", isStarred: false),
        Repository(id: 12, name: "Alamofire/Alamofire", description: "Elegant HTTP Networking in Swift", isStarred: false),
    ]
    
    func sendRequest<Request: APIRequest>(_ request: Request) -> Single<Request.Response> {
        switch request {
        case is ListRepositoriesRequest:
            let response = ListRepositoriesResponse(repositories: repositories)
            return Single
                .just(response as! Request.Response)
                .delay(2, scheduler: SharingScheduler.make())
        case let request as StarRepositoryRequest:
            var repository = repositories.first(where: { $0.id == request.id })!
            repository.isStarred = true
            let response = StarRepositoryResponse(repository: repository)
            return Single
                .just(response as! Request.Response)
                .delay(1, scheduler: SharingScheduler.make())
        case let request as UnstarRepositoryRequest:
            var repository = repositories.first(where: { $0.id == request.id })!
            repository.isStarred = false
            let response = UnstarRepositoryResponse(repository: repository)
            return Single
                .just(response as! Request.Response)
                .delay(1, scheduler: SharingScheduler.make())
        default:
            return Single.error(RxError.unknown)
        }
    }
}
