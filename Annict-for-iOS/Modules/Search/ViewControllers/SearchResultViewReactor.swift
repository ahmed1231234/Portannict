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
    typealias Work = SearchWorksByTitleQuery.Data.SearchWork.Edge.Node

    enum Action {
        case search(String)
        case clear
    }

    enum Mutation {
        case setWorks([Work])
    }

    struct State {
        var works: [Work] = []
    }

    var initialState: State

    private let client = AnnictGraphQL.client

    init() {
        initialState = State()
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .search(let keyword):
            return search(keyword: keyword)
                .map { $0.searchWorks?.elements }
                .filterNil()
                .map { .setWorks($0) }
        case .clear:
            return .just(.setWorks([]))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setWorks(let works):
            state.works = works
        }
        return state
    }

    private func search(keyword: String) -> Observable<SearchWorksByTitleQuery.Data> {
        let query = SearchWorksByTitleQuery(title: keyword)
        return client.rx.fetch(query: query, cachePolicy: .returnCacheDataAndFetch)
    }
}

extension SearchWorksByTitleQuery.Data.SearchWork {
    var elements: [Edge.Node] {
        guard let edges = edges else { return []}
        return edges.compactMap { $0?.node }
    }
}
