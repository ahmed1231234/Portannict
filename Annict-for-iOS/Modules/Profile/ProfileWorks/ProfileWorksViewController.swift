//
//  ProfileWorksViewController.swift
//  Annict-for-iOS
//
//  Created by Yuto Akiba on 2019/01/16.
//  Copyright © 2019 Yuto Akiba. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import XLPagerTabStrip

final class ProfileWorksViewController: ChildPagerViewController, StoryboardView {
    typealias Reactor = ProfileWorksViewReactor

    var disposeBag = DisposeBag()

    @IBOutlet weak var collectionView: UICollectionView!

    private let column: Int = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(cellTypes: ProfileWorkCollectionViewCell.self)
    }

    func bind(reactor: Reactor) {
        rx.viewWillAppear
            .take(1)
            .map { Reactor.Action.fetch }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        collectionView.rx.setDataSource(self)
            .disposed(by: disposeBag)
        
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        collectionView.rx.contentOffset
            .subscribe(onNext: { [weak self] offset in
                guard let self = self else { return }
                self.delegate?.scrollViewDidScrolled(self.collectionView)
            })
            .disposed(by: disposeBag)

        collectionView.rx.triggeredPagination()
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .map { Reactor.Action.loadMore }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.works }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }

    override func provideScrollView() -> UIScrollView? {
        return collectionView
    }
}

extension ProfileWorksViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let reactor = reactor else { return 0 }
        return reactor.currentState.works.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(type: ProfileWorkCollectionViewCell.self, for: indexPath)
        guard let reactor = reactor else { return cell }
        let work = reactor.currentState.works[indexPath.item]
        cell.configure(work: work)
        cell.setColumnCount(column)
        return cell
    }
}

extension ProfileWorksViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let mergin: CGFloat = 18
        let column = CGFloat(self.column)
        let width = (collectionView.bounds.width - mergin * (column + 1)) / column
        return CGSize(width: width, height: width * 1.4 + 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 18, bottom: 0, right: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let reactor = reactor?.reactorForWork(index: indexPath.item) else { return }
        WorkViewController.presentPanModal(fromVC: self, reactor: reactor)
    }
}

extension ProfileWorksViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: reactor?.statusState.localizedText)
    }
}
