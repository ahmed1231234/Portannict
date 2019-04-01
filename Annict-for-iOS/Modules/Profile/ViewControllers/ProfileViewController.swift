//
//  ProfileViewController.swift
//  Annict-for-iOS
//
//  Created by Yuto Akiba on 2018/10/29.
//  Copyright © 2018 Yuto Akiba. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import Apollo
import XLPagerTabStrip

final class ProfileViewController: ParentPagerViewController, StoryboardView {
    enum Const {
        static let normalTextColor = UIColor(hex: 0x8E8E8E)
        static let selectedBackgroundColor = UIColor(hex: 0xEFEFEF)
        static let selectedTextColor = UIColor(hex: 0x333333)
    }
    
    typealias Reactor = ProfileViewReactor
    
    var disposeBag = DisposeBag()
    
    @IBOutlet private weak var headerView: ProfileHeaderView!
    
    private var buttonMarkView: ButtonMarkView? {
        return buttonBarView as? ButtonMarkView
    }
    
    override func viewDidLoad() {
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.buttonBarItemTitleColor = Const.normalTextColor
        settings.style.buttonBarLeftContentInset = 24
        settings.style.buttonBarRightContentInset = 24
        settings.style.buttonBarItemsShouldFillAvailableWidth = true

        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            newCell?.label.textColor = Const.selectedTextColor
            oldCell?.label.textColor = Const.normalTextColor
        }
        
        reactor = Reactor()
        
        buttonMarkView?.selectedMarkView.backgroundColor = Const.selectedBackgroundColor
        
        super.viewDidLoad()

        let statusBarBackgroundView = UIView(frame: UIApplication.shared.statusBarFrame)
        statusBarBackgroundView.backgroundColor = .white
        view.addSubview(statusBarBackgroundView)
    }
    
    func bind(reactor: Reactor) {
        rx.viewWillAppear
            .map { Reactor.Action.fetch }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.viewer }
            .filterNil()
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] viewer in
                self?.headerView.prepare(user: viewer)
                self?.refreshTableViewContentInsetTop()
            })
            .disposed(by: disposeBag)
    }
    
    override func viewControllers(_ parentPager: ParentPager) -> [ChildPagerViewController] {
        let vc1 = ProfileWorksViewController.loadStoryboard(reactor: .init(statusState: .watching))
        let vc2 = ProfileWorksViewController.loadStoryboard(reactor: .init(statusState: .wannaWatch))
        let vc3 = ProfileWorksViewController.loadStoryboard(reactor: .init(statusState: .watched))
        let vc4 = ProfileWorksViewController.loadStoryboard(reactor: .init(statusState: .onHold))
        let vc5 = ProfileWorksViewController.loadStoryboard(reactor: .init(statusState: .stopWatching))
        let vcs = [vc1, vc2, vc3, vc4, vc5]
        return vcs
    }
    
    override func headerView(_ parentPager: ParentPager) -> UIView {
        return headerView
    }
    
    private func refreshTableViewContentInsetTop() {
        viewControllers
            .compactMap { ($0 as? ScrollViewProvider)?.provideScrollView() }
            .forEach {
                $0.contentInset.top = insetTop
                $0.scrollIndicatorInsets.top = insetTop
                $0.contentOffset.y = -insetTop
            }
    }
}

extension UIColor {
    public convenience init(from fColor: UIColor, to tColor: UIColor, with per: CGFloat) {
        var fR: CGFloat = 0, fG: CGFloat = 0, fB: CGFloat = 0, fA: CGFloat = 0
        var tR: CGFloat = 0, tG: CGFloat = 0, tB: CGFloat = 0, tA: CGFloat = 0
        
        fColor.getRed(&fR, green: &fG, blue: &fB, alpha: &fA)
        tColor.getRed(&tR, green: &tG, blue: &tB, alpha: &tA)
        
        let r: CGFloat = (tR - fR) * per + fR
        let g: CGFloat = (tG - fG) * per + fG
        let b: CGFloat = (tB - fB) * per + fB
        let a: CGFloat = (tA - fA) * per + fA
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
