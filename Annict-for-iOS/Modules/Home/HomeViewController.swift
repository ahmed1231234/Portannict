//
//  HomeViewController.swift
//  Annict-for-iOS
//
//  Created by Yuto Akiba on 2018/10/23.
//  Copyright © 2018 Yuto Akiba. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift

final class HomeViewController: UIViewController, StoryboardView {
    typealias Reactor = HomeViewReactor

    @IBOutlet weak var tableView: UITableView!

    var disposeBag = DisposeBag()

    private let refreshControl = UIRefreshControl()
    
    private var cellHeightList: [IndexPath: CGFloat] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(ActivityRecordTableViewCell.self,
                           ActivityStatusTableViewCell.self,
                           ActivityMultipleRecordTableViewCell.self,
                           HomeTitleTableViewCell.self)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refreshControl
        tableView.delaysContentTouches = false
    }
    
    func bind(reactor: Reactor) {
        rx.viewWillAppear
            .take(1)
            .map { Reactor.Action.fetchActivities }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        tableView.rx.setDataSource(self)
            .disposed(by: disposeBag)

        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)

        tableView.rx.triggeredPagination()
            .map { Reactor.Action.loadMore }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.forceFetch }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state.map { $0.items }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .filter { !$0 }
            .subscribe(onNext: { [weak self] _ in
                self?.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
    }
}

extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return reactor!.currentState.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(classType: HomeTitleTableViewCell.self, for: indexPath)
            cell.configure(title: "Home")
            return cell
        }
        
        guard let reactor = reactor else { return .init() }
        let item = reactor.currentState.items[indexPath.row]
        switch item {
        case .status(let reactor):
            let cell = tableView.dequeueReusableCell(classType: ActivityStatusTableViewCell.self, for: indexPath)
            cell.reactor = reactor
            cell.delegate = self
            return cell
        case .record(let reactor):
            let cell = tableView.dequeueReusableCell(classType: ActivityRecordTableViewCell.self, for: indexPath)
            cell.reactor = reactor
            cell.delegate = self
            return cell
        case .review:
            return .init()
        case .multiRecord(let reactor):
            let cell = tableView.dequeueReusableCell(classType: ActivityMultipleRecordTableViewCell.self, for: indexPath)
            cell.reactor = reactor
            cell.delegate = self
            return cell
        }
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return
        }
        
        if !cellHeightList.keys.contains(indexPath) {
            cellHeightList[indexPath] = cell.frame.height
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        }
        
        guard let height = self.cellHeightList[indexPath] else {
            return UITableView.automaticDimension
        }
        return height
    }
}

extension HomeViewController: HomeCellDelegate {
    func didSelect(item: HomeSectionItem) {
        guard let work = item.work else { return }
        let r = reactor!.reactorForWork(work: work)
        WorkViewController.presentPanModal(fromVC: self, reactor: r)
    }
    
    func didTapUnderArrow(_ cell: UITableViewCell, item: HomeSectionItem) {
        guard let user = item.user else { return }
        showAlert(cell: cell, user: user)
    }
    
    private func showAlert(cell: UITableViewCell, user: MinimumUser) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: "投稿を報告する", style: .default, handler: nil)
        let blockAction = UIAlertAction(title: "ユーザーをブロックする", style: .default) { [weak self] _ in
            self?.reactor?.action.onNext(.block(user.annictId))
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        alert.addAction(reportAction)
        alert.addAction(blockAction)
        alert.addAction(cancelAction)
        alert.popoverPresentationController?.sourceView = cell.contentView
        alert.popoverPresentationController?.sourceRect = cell.contentView.frame
        present(alert, animated: true, completion: nil)
    }
}
