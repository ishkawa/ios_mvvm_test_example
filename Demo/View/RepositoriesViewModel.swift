//
//  RepositoriesViewModel.swift
//  Demo
//
//  Created by Yosuke Ishikawa on 2019/01/14.
//  Copyright © 2019 Yosuke Ishikawa. All rights reserved.
//

import Foundation
import DIKit
import DataSourceKit
import RxSwift
import RxCocoa

final class RepositoriesViewModel: Injectable {
    struct Dependency {
        let starToggledIndex: Signal<Int>
        let apiClient: APIClient
    }
    
    enum CellDeclaration: Equatable {
        case empty(isLoading: Bool)
        case repository(Repository)
    }
    
    struct State: CellsDeclarator, Mutatable {
        var repositories = [] as [Repository]
        var isLoading = false
        
        var cells: [CellDeclaration] {
            if repositories.isEmpty {
                return [.empty(isLoading: isLoading)]
            } else {
                return repositories.map { .repository($0) }
            }
        }
        
        func declareCells(_ cell: (CellDeclaration) -> Void) {
            guard !repositories.isEmpty else {
                cell(.empty(isLoading: isLoading))
                return
            }
            
            for repository in repositories {
                cell(.repository(repository))
            }
        }
    }
    
    private let stateRelay = BehaviorRelay(value: State())

    private(set) lazy var cellDeclarations = stateRelay.asDriver()
        .map { $0.cellDeclarations }
        .distinctUntilChanged()

    private let disposeBag = DisposeBag()
    private let dependency: Dependency

    init(dependency: Dependency) {
        self.dependency = dependency
        bindToggleStar()
        loadRepositories()
    }
    
    private func bindToggleStar() {
        let repositoryToToggle = dependency.starToggledIndex
            .withLatestFrom(stateRelay.asSignal { _ in .empty() }) { $1.repositories[$0] }

        stateRelay.asDriver()
            .map { $0.repositories }
            .distinctUntilChanged { $0.map { $0.id } == $1.map { $0.id } }
            .flatMapLatest { [dependency] repositories -> Signal<Repository> in
                let toggledRepositories = repositories
                    .map { repository -> Signal<Repository> in
                        return repositoryToToggle.asSignal()
                            .filter { $0.id == repository.id }
                            .flatMapLatest { originalRepository -> Signal<Repository> in
                                var toggledRepository = originalRepository
                                toggledRepository.isStarred.toggle()

                                let returnedRepository: Single<Repository>
                                if toggledRepository.isStarred {
                                    let request = StarRepositoryRequest(id: originalRepository.id)
                                    returnedRepository = dependency.apiClient
                                        .sendRequest(request)
                                        .map { $0.repository }
                                } else {
                                    let request = UnstarRepositoryRequest(id: originalRepository.id)
                                    returnedRepository = dependency.apiClient
                                        .sendRequest(request)
                                        .map { $0.repository }
                                }
                                
                                return returnedRepository
                                    .asSignal(onErrorJustReturn: originalRepository)
                                    .startWith(toggledRepository)
                        }
                }
                
                return Signal.merge(toggledRepositories)
            }
            .emit(onNext: { [stateRelay] updatedRepository in
                stateRelay.accept(stateRelay.value.mutated { state in
                    state.repositories = state.repositories.map { $0.id == updatedRepository.id ? updatedRepository : $0 }
                })
            })
            .disposed(by: disposeBag)
    }

    private func loadRepositories() {
        guard !stateRelay.value.isLoading else {
            return
        }
        
        stateRelay.accept(stateRelay.value.mutated { $0.isLoading = true })

        let request = ListRepositoriesRequest()
        
        dependency.apiClient
            .sendRequest(request)
            .subscribe { [stateRelay] event in
                stateRelay.accept(stateRelay.value.mutated { state in
                    state.isLoading = false
                    
                    if case .success(let response) = event {
                        state.repositories = response.repositories
                    }
                })
            }
            .disposed(by: disposeBag)
    }
}
