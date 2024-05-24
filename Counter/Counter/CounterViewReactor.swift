//
//  CounterViewReactor.swift
//  Counter
//
//  Created by 홍진표 on 5/24/24.
//

import Foundation
import ReactorKit
import RxSwift

final class CounterViewReactor: Reactor {
    
    // MARK: - View의 Action 정의
    /// `Action is an user interaction`
    enum Action {   //  추상화 된 사용자 입력
        //  사용자 입력..
        case increase
        case decrease
    }
    
    // MARK: - Action을 받을 Mutation 정의
    /// `Mutate is a state manipulator which is not exposed to a view`
    enum Mutation {
        case increaseValue
        case decreaseValue
        case setLoading(Bool)
    }
    
    // MARK: - State is a current view state
    struct State {  //  추상화 된 뷰 상태
        //  뷰 상태..
        var value: Int
        var isLoading: Bool
    }
    
    var initialState: State
    
    init() {
        self.initialState = State(value: 0, isLoading: false)
    }
    
    // MARK: - Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .increase:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                Observable.just(Mutation.increaseValue)
                    .delay(.seconds(1), scheduler: MainScheduler.instance),
                Observable.just(Mutation.setLoading(false))
            ])
            
            /// `concat()`:  두 개 이상의 Observable을 interleaving (간섭) 하지 않고 방출함
            /// -> Stream을 하나로 합쳐 순서대로 동작
        case .decrease:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                Observable.just(Mutation.decreaseValue)
                    .delay(.seconds(1), scheduler: MainScheduler.instance),
                Observable.just(Mutation.setLoading(false))
            ])
        }
    }
    
    // MARK: - Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState: State = state
        
        switch mutation {
        case .increaseValue:
            newState.value += 1; break;
        case .decreaseValue:
            newState.value -= 1; break;
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        }
        
        return newState
    }
}
