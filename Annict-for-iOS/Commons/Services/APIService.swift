//
//  APIService.swift
//  Annict-for-iOS
//
//  Created by Yuto Akiba on 2018/10/24.
//  Copyright © 2018 Yuto Akiba. All rights reserved.
//

import RxSwift
import Apollo

protocol APIServiceType {
    func getOauthToken(code: String) -> Single<OauthTokenRequest.Response>
    func fetchFollowingActivities(after: String?, cachePolicy: CachePolicy) -> Observable<GetFollowingActivitiesQuery.Data>
}

final class APIService: BaseService, APIServiceType {
    func getOauthToken(code: String) -> Single<OauthTokenRequest.Response> {
        let request = OauthTokenRequest(code: code)
        return HTTPClient.send(request: request)
    }

    func fetchFollowingActivities(after: String?, cachePolicy: CachePolicy) -> Observable<GetFollowingActivitiesQuery.Data> {
        let query = GetFollowingActivitiesQuery(after: after)
        return AnnictGraphQL.client.rx.fetch(query: query, cachePolicy: cachePolicy)
            .asObservable()
            .take(cachePolicy.takeCount)
    }
}
