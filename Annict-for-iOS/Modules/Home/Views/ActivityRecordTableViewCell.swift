//
//  ActivityRecordTableViewCell.swift
//  Annict-for-iOS
//
//  Created by Yuto Akiba on 2019/03/12.
//  Copyright © 2019 Yuto Akiba. All rights reserved.
//

import UIKit
import SwiftDate
import ReactorKit
import RxSwift

protocol HomeQuoteViewCellDelegate: class {
    func didSelect(item: HomeSectionItem)
}

final class ActivityRecordTableViewCell: UITableViewCell, StoryboardView {
    typealias Reactor = ActivityRecordTableViewCellReactor

    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var workAndEpisodeQuoteView: WorkAndEpisodeQuoteView!
    @IBOutlet private weak var recordStatusTagView: RecordStatusTagView!

    var disposeBag = DisposeBag()
    weak var delegate: HomeQuoteViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = 40 / 2
        workAndEpisodeQuoteView.delegate = self
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        disposeBag = DisposeBag()
        workAndEpisodeQuoteView.delegate = self
    }

    func bind(reactor: Reactor) {
        reactor.state.map { $0.record }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] record in
                self?.configure(activityItem: record)
            })
            .disposed(by: disposeBag)
    }

    func configure(activityItem: HomeViewReactor.Activity.AsRecord) {
        let record = activityItem.fragments.minimumRecord
        let user = record.user.fragments.minimumUser
        avatarImageView.setImage(url: user.avatarUrl)
        nameLabel.text = user.name
        usernameLabel.text = "@" + user.username
        timeLabel.text = record.createdAt.toDate()?.toRelative()
        messageLabel.text = record.comment
        workAndEpisodeQuoteView.configure(work: activityItem.work.fragments.minimumWork,
                                          episode: activityItem.episode.fragments.minimumEpisode)
        if let ratingState = record.ratingState {
            recordStatusTagView.isHidden = false
            recordStatusTagView.configure(ratingState: ratingState)
        } else {
            recordStatusTagView.isHidden = true
        }
    }
}

extension ActivityRecordTableViewCell: QuoteViewDelegate {
    func didSelect() {
        delegate?.didSelect(item: .record(reactor!))
    }
}
