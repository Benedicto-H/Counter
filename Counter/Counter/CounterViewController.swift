//
//  ViewController.swift
//  Counter
//
//  Created by 홍진표 on 5/24/24.
//

import UIKit
import SwiftUI

import SnapKit
import ReactorKit
import RxSwift
import RxCocoa

final class CounterViewController: UIViewController, ReactorKit.StoryboardView {

    // MARK: - Rx
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - UI
    private let decreaseButton: UIButton = {
        let button: UIButton = UIButton()
        
        button.setImage(UIImage(systemName: "minus"), for: .normal)
        return button
    }()
    
    private let valueLabel: UILabel = {
        let label: UILabel = UILabel()
        
        label.textColor = UIColor(dynamicProvider: { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        })
        label.font = .systemFont(ofSize: 20.0, weight: .semibold)
        return label
    }()
    
    private let increaseButton: UIButton = {
        let button: UIButton = UIButton()
        
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        return button
    }()
    
    private let stackView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private let indicator: UIActivityIndicatorView = {
        let indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)
        
        indicator.color = .gray
        return indicator
    }()
    
    // MARK: - Methods
    init(reactor: CounterViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setup()
    }
    
    private func setup() -> Void {
        
        Array(arrayLiteral: decreaseButton, valueLabel, increaseButton)
            .forEach { stackView.addArrangedSubview($0) }
        
        self.view.addSubview(stackView)
        self.view.addSubview(indicator)
        
        stackView.snp.makeConstraints { make in
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading).inset(100)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing).inset(100)
            make.centerX.centerY.equalToSuperview()
        }
        
        indicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(stackView).offset(50)
        }
    }
    
    // MARK: - using ReactorKit.StoryboardView (Pr): ReactorKit.View
    func bind(reactor: CounterViewReactor) {
        /// ReactorKit.StoryboardView (Pr) - `bind(reactor: Reactor)`: view가 로드되면 호출됨
        
        //  Action
        //  decreaseButton / increaseButton 버튼 tap시, Action 발생
        decreaseButton.rx.tap                   // Tap event
            .map { Reactor.Action.decrease }    // Convert to Action.decrease
            .bind(to: reactor.action)           // Bind to reactor.action
            .disposed(by: self.disposeBag)
        
        increaseButton.rx.tap
            .map { Reactor.Action.increase }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        //  State
        reactor.state
            .map { $0.value }
            .distinctUntilChanged()
            .map { String(stringLiteral: "\($0)") }
            .bind(to: valueLabel.rx.text)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .bind(to: indicator.rx.isAnimating)
            .disposed(by: self.disposeBag)
        
        // MARK: - ReactorKit.View (Pr) - bind(reactor: Reactor)
        /// - warning: It's not recommended to call this method directly.
        /// Called when the new value is assigned to `self.reactor` (-> `self.reactor`가 바뀌면 호출됨)
    }


}

#if DEBUG
/*
struct CounterViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        CounterViewController(reactor: CounterViewReactor())
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

struct CounterViewControllerRepresentable_PreviewProvider: PreviewProvider {
    static var previews: some SwiftUI.View {
        CounterViewControllerRepresentable()
            .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro"))
            .previewDisplayName("CounterViewController_Preview")
            .preferredColorScheme(.light)
            .ignoresSafeArea()
    }
}
 */

#Preview("CounterViewController_Preview", body: {
    CounterViewController(reactor: CounterViewReactor())
})
#endif

