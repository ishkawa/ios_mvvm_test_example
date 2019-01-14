//
//  RepositoriesViewModelTests.swift
//  DemoTests
//
//  Created by Yosuke Ishikawa on 2019/01/14.
//  Copyright © 2019 Yosuke Ishikawa. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest

@testable import Demo

final class RepositoriesViewModelTests: XCTestCase {
    var scheduler: TestScheduler!
    var appResolver: TestAppResolver!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        scheduler = TestScheduler(initialClock: 0)
        appResolver = TestAppResolver()
        disposeBag = DisposeBag()
    }
    
    func testLoad() {
        let repository1 = makeRepository(id: 1, isStarred: false)
        let repository2 = makeRepository(id: 2, isStarred: false)
        let repository3 = makeRepository(id: 3, isStarred: false)
        stubListRepositories(returnRepositories: [repository1, repository2, repository3], delay: 5)

        let viewModel = appResolver.resolveRepositoriesViewModel(starToggledIndex: Signal.never())
        let cellDeclarations = recordCellDeclarations(of: viewModel)
        scheduler.start()
        
        XCTAssertEqual(cellDeclarations.events, [
            next(0, [
                .empty(isLoading: true),
            ]),
            next(5, [
                .repository(repository1),
                .repository(repository2),
                .repository(repository3),
            ]),
        ])
    }
    
    func testLoadError() {
        stubListRepositories(returnError: RxError.unknown, delay: 5)
        
        let viewModel = appResolver.resolveRepositoriesViewModel(starToggledIndex: Signal.never())
        let cellDeclarations = recordCellDeclarations(of: viewModel)
        scheduler.start()
        
        XCTAssertEqual(cellDeclarations.events, [
            next(0, [
                .empty(isLoading: true),
            ]),
            next(5, [
                .empty(isLoading: false),
            ]),
        ])
    }
    
    func testToggleStar() {
        let repository1 = makeRepository(id: 1, isStarred: false)
        let repository2 = makeRepository(id: 2, isStarred: false)
        stubListRepositories(returnRepositories: [repository1, repository2], delay: 5)
        
        let repository1Starred = repository1.mutated { $0.isStarred = true }
        stubStarRepository(id: repository1.id, returnRepository: repository1Starred, delay: 5)
        stubUnstarRepository(id: repository1.id, returnRepository: repository1, delay: 5)

        let viewModel = appResolver.resolveRepositoriesViewModel(
            starToggledIndex: scheduler.createHotObservable([
                next(10, 0),
                next(20, 0),
            ]).asSignal { _ in .empty() })
        
        let cellDeclarations = recordCellDeclarations(of: viewModel)
        scheduler.start()
        
        XCTAssertEqual(cellDeclarations.events, [
            next(0, [
                .empty(isLoading: true),
            ]),
            next(5, [
                .repository(repository1),
                .repository(repository2),
            ]),
            next(10, [
                .repository(repository1Starred),
                .repository(repository2),
            ]),
            next(20, [
                .repository(repository1),
                .repository(repository2),
            ]),
        ])
    }
    
    func testToggleStarError() {
        let repository1 = makeRepository(id: 1, isStarred: false)
        let repository2 = makeRepository(id: 2, isStarred: false)
        stubListRepositories(returnRepositories: [repository1, repository2], delay: 5)
        
        let repository1Starred = repository1.mutated { $0.isStarred = true }
        stubStarRepository(id: repository1.id, returnError: RxError.unknown, delay: 5)

        let viewModel = appResolver.resolveRepositoriesViewModel(
            starToggledIndex: scheduler.createHotObservable([
                next(10, 0),
            ]).asSignal { _ in .empty() })
        
        let cellDeclarations = recordCellDeclarations(of: viewModel)
        scheduler.start()
        
        XCTAssertEqual(cellDeclarations.events, [
            next(0, [
                .empty(isLoading: true),
            ]),
            next(5, [
                .repository(repository1),
                .repository(repository2),
            ]),
            next(10, [
                .repository(repository1Starred),
                .repository(repository2),
            ]),
            next(15, [
                .repository(repository1),
                .repository(repository2),
            ]),
        ])
    }
    
    func testToggleStarContinuously() {
        let repository1 = makeRepository(id: 1, isStarred: false)
        let repository2 = makeRepository(id: 2, isStarred: false)
        stubListRepositories(returnRepositories: [repository1, repository2], delay: 5)
        
        let repository1Starred = repository1.mutated { $0.isStarred = true }
        stubStarRepository(id: repository1.id, returnError: RxError.unknown, delay: 5)
        stubUnstarRepository(id: repository1.id, returnError: RxError.unknown, delay: 5)
        stubStarRepository(id: repository1.id, returnError: RxError.unknown, delay: 5)
        stubUnstarRepository(id: repository1.id, returnRepository: repository1, delay: 5)
        
        let repository2Starred = repository2.mutated { $0.isStarred = true }
        stubStarRepository(id: repository2.id, returnError: RxError.unknown, delay: 5)
        stubUnstarRepository(id: repository2.id, returnError: RxError.unknown, delay: 5)
        stubStarRepository(id: repository2.id, returnRepository: repository2Starred, delay: 5)

        let viewModel = appResolver.resolveRepositoriesViewModel(
            starToggledIndex: scheduler.createHotObservable([
                next(10, 0),
                next(11, 1),
                next(12, 0),
                next(13, 1),
                next(14, 0),
                next(15, 1),
                next(16, 0),
            ]).asSignal { _ in .empty() })
        
        let cellDeclarations = recordCellDeclarations(of: viewModel)
        scheduler.start()
        
        XCTAssertEqual(cellDeclarations.events, [
            next(0, [
                .empty(isLoading: true),
            ]),
            next(5, [
                .repository(repository1),
                .repository(repository2),
            ]),
            next(10, [
                .repository(repository1Starred),
                .repository(repository2),
            ]),
            next(11, [
                .repository(repository1Starred),
                .repository(repository2Starred),
            ]),
            next(12, [
                .repository(repository1),
                .repository(repository2Starred),
            ]),
            next(13, [
                .repository(repository1),
                .repository(repository2),
            ]),
            next(14, [
                .repository(repository1Starred),
                .repository(repository2),
            ]),
            next(15, [
                .repository(repository1Starred),
                .repository(repository2Starred),
            ]),
            next(16, [
                .repository(repository1),
                .repository(repository2Starred),
            ]),
        ])
    }
}

extension RepositoriesViewModelTests {
    private func makeSignal<Value>(time: RxTimeInterval, value: Value) -> Signal<Value> {
        var signal: Signal<Value> = Signal.empty()
        SharingScheduler.mock(scheduler: scheduler) {
            signal = Signal
                .just(value)
                .delay(time)
        }
        return signal
    }
    
    private func makeRepository(id: Int64, isStarred: Bool) -> Repository {
        return Repository(id: id, name: "", description: "", isStarred: isStarred)
    }
    
    private func stubListRepositories(returnRepositories: [Repository], delay: RxTimeInterval) {
        appResolver.apiClient.stub(
            request: ListRepositoriesRequest(),
            response: Single
                .just(ListRepositoriesResponse(repositories: returnRepositories))
                .delay(delay, scheduler: scheduler))
    }
    
    private func stubListRepositories(returnError: Error, delay: RxTimeInterval) {
        appResolver.apiClient.stub(
            request: ListRepositoriesRequest(),
            response: Single
                .just(())
                .delay(delay, scheduler: scheduler)
                .map { _ in throw returnError })
    }
    
    private func stubStarRepository(id: Int64, returnRepository: Repository, delay: RxTimeInterval) {
        appResolver.apiClient.stub(
            request: StarRepositoryRequest(id: id),
            response: Single
                .just(StarRepositoryResponse(repository: returnRepository))
                .delay(delay, scheduler: scheduler))
    }
    
    private func stubStarRepository(id: Int64, returnError: Error, delay: RxTimeInterval) {
        appResolver.apiClient.stub(
            request: StarRepositoryRequest(id: id),
            response: Single
                .just(())
                .delay(delay, scheduler: scheduler)
                .map { _ in throw returnError })
    }

    private func stubUnstarRepository(id: Int64, returnRepository: Repository, delay: RxTimeInterval) {
        appResolver.apiClient.stub(
            request: UnstarRepositoryRequest(id: id),
            response: Single
                .just(UnstarRepositoryResponse(repository: returnRepository))
                .delay(delay, scheduler: scheduler))
    }
    
    private func stubUnstarRepository(id: Int64, returnError: Error, delay: RxTimeInterval) {
        appResolver.apiClient.stub(
            request: UnstarRepositoryRequest(id: id),
            response: Single
                .just(())
                .delay(delay, scheduler: scheduler)
                .map { _ in throw returnError })
    }

    private func recordCellDeclarations(of viewModel: RepositoriesViewModel) -> TestableObserver<[RepositoriesViewModel.CellDeclaration]> {
        let observer = scheduler.createObserver([RepositoriesViewModel.CellDeclaration].self)
        viewModel.cellDeclarations
            .drive(observer)
            .disposed(by: disposeBag)
        return observer
    }
}
