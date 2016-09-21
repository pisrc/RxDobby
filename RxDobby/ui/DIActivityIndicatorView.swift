//
//  DIActivityIndicatorView.swift
//  Dobby
//
//  Created by ryan on 4/21/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//
//  기본 loading indicator 제공을 위함

import UIKit
import RxSwift

protocol Bindable {
    func bindTo<T>(_ observable: Observable<T>)
}

public struct DIActivityIndicatorView: Bindable {
    fileprivate(set) var indicatorView: UIActivityIndicatorView
    fileprivate let disposeBag = DisposeBag()
    
    public init(centerAtView parentView: UIView, style: UIActivityIndicatorViewStyle) {
        
        // view 중앙에 indicator 생성
        indicatorView = UIActivityIndicatorView(activityIndicatorStyle: style)
        indicatorView.isUserInteractionEnabled = false
        parentView.addSubview(indicatorView)
        parentView.addConstraints([
            DConstraint.centerH(indicatorView, superview: parentView),
            DConstraint.centerV(indicatorView, superview: parentView)])
        
        indicatorView.startAnimating()
    }
    
    public func bindTo<T>(_ observable: Observable<T>) {
        observable.subscribe(
            onNext: nil,
            onError: nil,
            onCompleted: nil,
            onDisposed: {
                self.indicatorView.stopAnimating()
            })
            .addDisposableTo(disposeBag)
    }
}

