//
//  ListRepositories.swift
//  Demo
//
//  Created by Yosuke Ishikawa on 2019/01/14.
//  Copyright © 2019 Yosuke Ishikawa. All rights reserved.
//

struct ListRepositoriesRequest: APIRequest, Equatable {
    typealias Response = ListRepositoriesResponse
}

struct ListRepositoriesResponse: Equatable {
    var repositories: [Repository]
}

struct StarRepositoryRequest: APIRequest, Equatable {
    typealias Response = StarRepositoryResponse
    var id: Int64
}

struct StarRepositoryResponse: Equatable {
    var repository: Repository
}

struct UnstarRepositoryRequest: APIRequest, Equatable {
    typealias Response = UnstarRepositoryResponse
    var id: Int64
}

struct UnstarRepositoryResponse: Equatable {
    var repository: Repository
}
