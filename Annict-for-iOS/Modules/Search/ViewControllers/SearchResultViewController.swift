//
//  SearchResultViewController.swift
//  Annict-for-iOS
//
//  Created by Yuto Akiba on 2018/11/30.
//  Copyright © 2018 Yuto Akiba. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift

final class SearchResultViewController: UIViewController, StoryboardView {
    typealias Reactor = SearchResultViewReactor

    var disposeBag = DisposeBag()

    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        prepareTableView()
    }

    func bind(reactor: Reactor) {
        reactor.state.map { $0.works }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] works in
                print(works)
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }

    private func prepareTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .onDrag
        tableView.register(SearchResultWorkCell.self)
    }
}

extension SearchResultViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reactor?.currentState.works.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(classType: SearchResultWorkCell.self, for: indexPath)
        guard let work = reactor?.currentState.works[indexPath.row] else { return .init() }
        cell.configure(work: work)
        return cell
    }
}

extension SearchResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let reactor = reactor?.reactorForWork(index: indexPath.item) else { return }
        WorkViewController.presentPanModal(fromVC: self, reactor: reactor)
    }
}

extension SearchResultViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        view.isHidden = false
        guard let text = searchController.searchBar.text else { return }
        if text.isEmpty {
            reactor?.action.onNext(.clear)
            return
        }
        reactor?.action.onNext(.search(text))
    }
}

extension SearchResultViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        reactor?.action.onNext(.clear)
    }
}
