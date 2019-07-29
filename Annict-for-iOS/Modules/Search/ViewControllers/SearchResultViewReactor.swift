//
//  SearchResultViewReactor.swift
//  Annict-for-iOS
//
//  Created by Yuto Akiba on 2018/11/30.
//  Copyright © 2018 Yuto Akiba. All rights reserved.
//

import ReactorKit
import RxSwift

final class SearchResultViewReactor: Reactor {
    enum Action {
        case search(String)
        case clear
    }

    enum Mutation {
        case setWorks([MinimumWork])
        case updateWork(MinimumWork)
    }

    struct State {
        var works: [MinimumWork] = []
    }

    let initialState: State
    private let provider: ServiceProviderType
    private let client = AnnictGraphQL.client

    init(provider: ServiceProviderType) {
        initialState = State()
        self.provider = provider
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .search(let keyword):
            return search(keyword: keyword)
                .map { $0.searchWorks?.values }
                .filterNil()
                .map { $0.map { $0.fragments.minimumWork } }
                .map { .setWorks($0) }
        case .clear:
            return .just(.setWorks([]))
        }
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let updateStatus = provider.workAPIService.event.updateWorkState
            .map { Mutation.updateWork($0) }
        
        return .merge(mutation, updateStatus)
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setWorks(let works):
            state.works = works
        case .updateWork(let work):
            guard let index = state.works.firstIndex(where: { $0.id == work.id }) else { return state }
            state.works[index].viewerStatusState = work.viewerStatusState
        }
        return state
    }

    func reactorForWork(index: Int) -> WorkViewReactor {
        return .init(provider: provider, work: currentState.works[index])
    }

    private func search(keyword: String) -> Observable<SearchWorksByTitleQuery.Data> {
        let query = SearchWorksByTitleQuery(title: keyword)
        return client.rx.fetch(query: query, cachePolicy: .returnCacheDataAndFetch)
    }
}

extension SearchWorksByTitleQuery.Data.SearchWork: Connection {}

