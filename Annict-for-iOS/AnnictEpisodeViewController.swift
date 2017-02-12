//
//  AnnictEpisodeViewController.swift
//  Annict-for-iOS
//
//  Created by Yuto Akiba on 2017/02/12.
//  Copyright © 2017年 Yuto Akiba. All rights reserved.
//

import UIKit

import XLPagerTabStrip


// MARK: - AnnictEpisodeViewController

class AnnictEpisodeViewController: UITableViewController {
    
    // 外部から指定
    var workID: Int!
    
    fileprivate var episodes: [AnnictEpisodeResponse] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initTableView()
        
        let indicotor = self.initIndicatorView()
        self.getEpisodes() { _ in
            indicotor.stopAnimating()
        }
    }
    
    fileprivate func initTableView() {
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.register(cellType: AnnictEpisodeCell.self)
        self.initRefreshControl()
    }
    
    fileprivate func initRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.pulledTableView(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.annictPink.withAlphaComponent(0.7)
        self.refreshControl = refreshControl
    }
    
    fileprivate func initIndicatorView() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.center = CGPoint(x: view.bounds.midX, y: 16)
        indicator.color = .annictPink
        view.addSubview(indicator)
        indicator.startAnimating()
        return indicator
    }
    
    fileprivate func getEpisodes(completionHandler: (() -> Void)?) {
        let request = AnnictAPI.GetEpisodes(workID: workID)
        AnnictAPIClient.send(request) { response in
            switch response {
            case .success(let value):
                self.episodes = value.episodes
                completionHandler?()
            case .failure(let error):
                print(error)
                completionHandler?()
            }
        }
    }
    
    func pulledTableView(_ refreshControl: UIRefreshControl) {
        self.getEpisodes() { _ in
            self.refreshControl?.endRefreshing()
        }
    }
}

extension AnnictEpisodeViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: AnnictEpisodeCell.self, for: indexPath)
        cell.set(episode: episodes[indexPath.row])
        return cell
    }
}

extension AnnictEpisodeViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "エピソード")
    }
}