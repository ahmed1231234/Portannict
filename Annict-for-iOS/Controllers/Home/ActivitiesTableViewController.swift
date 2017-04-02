//
//  ActivitiesTableViewController.swift
//  Annict-for-iOS
//
//  Created by Yuto Akiba on 2017/04/02.
//  Copyright © 2017年 Yuto Akiba. All rights reserved.
//

import UIKit

class ActivitiesTableViewController: UITableViewController {
    
    fileprivate var state = TableViewState.idol
    fileprivate var currentPage = 0
    
    fileprivate var activities: [AnnictActivityResponse] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "home".localized(withTableName: "AnnictBaseLocalizable")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        initTableView()
        initRefreshControl()
        startRefreshControlAnimation()
        getMeFollowingActivities() { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.shadowImage = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    @objc private func pulledTableView(_ refreshControl: UIRefreshControl) {
        currentPage = 0
        getMeFollowingActivities() { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
    
    fileprivate func getMeFollowingActivities(completionHandler: (() -> Void)? = nil) {
        let nextPage = self.currentPage+1
        state = .loading
        let request = AnnictAPI.GetMeFollowingActivities(page: nextPage)
        AnnictAPIClient.send(request) { [weak self] response in
            switch response {
            case .success(let value):
                // 初回、pull更新時
                if self?.currentPage == 0 {
                    self?.activities = value.activities
                } else {
                    self?.activities += value.activities
                }
                self?.currentPage += 1
                self?.state = .idol
                completionHandler?()
            case .failure(let error):
                print(error)
                self?.state = .idol
                completionHandler?()
            }
        }
    }
    
    private func initTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 240
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(cellTypes: [AnnictActivityCreateStatusCell.self,
                                       AnnictActivityCreateRecordCell.self,
                                       AnnictActivityCreateMultipleRecordsCell.self])
    }
    
    private func initRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.pulledTableView(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.annictPink.withAlphaComponent(0.7)
        self.refreshControl = refreshControl
    }
    
    private func startRefreshControlAnimation() {
        tableView.contentOffset.y = -self.refreshControl!.bounds.height
        self.refreshControl?.beginRefreshing()
    }
}

extension ActivitiesTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getActivityCell(activity: activities[indexPath.row], indexPath: indexPath)
    }
    
    fileprivate func getActivityCell(activity: AnnictActivityResponse, indexPath: IndexPath) -> UITableViewCell {
        guard let action = activity.action else { return UITableViewCell() }
        
        switch action {
        case .createRecord:
            let cell = tableView.dequeueReusableCell(with: AnnictActivityCreateRecordCell.self, for: indexPath)
            cell.set(activity: activity)
            return cell
        case .createMultipleRecords:
            let cell = tableView.dequeueReusableCell(with: AnnictActivityCreateMultipleRecordsCell.self, for: indexPath)
            cell.set(activity: activity)
            return cell
        case .createStatus:
            let cell = tableView.dequeueReusableCell(with: AnnictActivityCreateStatusCell.self, for: indexPath)
            cell.set(activity: activity)
            return cell
        }
    }
}

extension ActivitiesTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let action = activities[indexPath.row].action else { return }
        
        switch action {
        case .createRecord:
            guard let episodeID = activities[indexPath.row].episode?.id else { return }
            let annictRecordsTabViewController = AnnictRecordsTabViewController.instantiate(withStoryboard: .annictWorks)
            annictRecordsTabViewController.episodeID = episodeID
            navigationController?.pushViewController(annictRecordsTabViewController, animated: true)
        case .createStatus, .createMultipleRecords:
            guard let work = activities[indexPath.row].work else { return }
            let annictDetailAnimeInfoTabViewController = AnnictDetailAnimeInfoTabViewController.instantiate(withStoryboard: .annictWorks)
            annictDetailAnimeInfoTabViewController.work = work
            navigationController?.pushViewController(annictDetailAnimeInfoTabViewController, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == activities.count - 20 && self.state == .idol {
            getMeFollowingActivities()
        }
    }
}