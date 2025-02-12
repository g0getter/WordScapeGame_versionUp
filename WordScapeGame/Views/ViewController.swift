//
//  ViewController.swift
//  WordScapeGame
//
//  Created by 여나경 on 2/8/25.
//

import UIKit
import SnapKit
import Then
import ReactorKit
import RxSwift // to use ReactorKit
import RxCocoa // to bind a button tap to reactor action (emit reactor action using map

class ViewController: UIViewController, ReactorKit.View {

    var disposeBag = DisposeBag()
    var reactor: ViewReactor?
    
    var initialWords: [Word] = []
    var wordsWithAnimators: [String: UIViewPropertyAnimator] = [:]
    var wordsWithWordViews: [String: WordView] = [:]
    
    private let wordLanes = UIView().then {
        $0.backgroundColor = .lightGray
    }
    private let capturedWordsLabel = UILabel().then {
        $0.text = "Captured Words"
    }
    private let missedWordsLabel = UILabel().then {
        $0.text = "Missed Words"
    }
    
    private let capturedWordsBox = UIView().then {
        $0.backgroundColor = .blue.withAlphaComponent(0.5)
    }
    private let capturedWordsContent = UIStackView().then {
        $0.axis = .vertical
    }
    
    private let missedWordsBox = UIView().then {
        $0.backgroundColor = .red.withAlphaComponent(0.5)
    }
    private let missedWordsContent = UIStackView().then {
        $0.axis = .vertical
    }
    
    private let startButton = UIButton().then {
        $0.setTitle("Start", for: .normal)
        $0.backgroundColor = .green
    }
    private let resetButton = UIButton().then {
        $0.setTitle("Reset", for: .normal)
        $0.backgroundColor = .green
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: 자동화
        initialWords = [
            Word(text: "apple", laneType: .laneA, priorityInLane: 0, topOffset: 0),
            Word(text: "apricot", laneType: .laneA, priorityInLane: 1, topOffset: 30),
            
            Word(text: "banana", laneType: .laneB, priorityInLane: 0, topOffset: 90),
            Word(text: "blueberry", laneType: .laneB, priorityInLane: 1, topOffset: 120),
            
            Word(text: "cherry", laneType: .laneC, priorityInLane: 0, topOffset: 180),
            Word(text: "coconut", laneType: .laneC, priorityInLane: 1, topOffset: 210),
        ]
        
        setupWordViews(initialWords) // should be called first
        
        // UIs
        addSubviews()
        setupConstraints()
        
        // TapGestures
        wordsWithWordViews.values.forEach {
            setupTapGesture(to: $0)
        }
        
        reactor = ViewReactor(words: initialWords)
        guard let reactor = reactor else { return }
        bind(reactor: reactor)
    }
}

// MARK: - UI setting
extension ViewController {
    
    private func setupWordViews(_ words: [Word]) {
        words.forEach { word in
            wordsWithWordViews[word.text] = WordView(text: word.text)
        }
    }
    
    private func addSubviews() {
        [
            wordLanes,
            capturedWordsLabel,
            missedWordsLabel,
            capturedWordsBox,
            missedWordsBox,
            startButton,
            resetButton
        ]
            .forEach { view.addSubview($0) }
        wordsWithWordViews.values.forEach { wordLanes.addSubview($0) }
        
        capturedWordsBox.addSubview(capturedWordsContent)
        missedWordsBox.addSubview(missedWordsContent)
    }
    
    private func setupConstraints() {
        wordLanes.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.leading.trailing.equalToSuperview().inset(10)
        }
        
        capturedWordsLabel.snp.makeConstraints {
            $0.top.equalTo(wordLanes.snp.bottom).offset(20)
            $0.top.equalTo(view.snp.centerY)
            $0.leading.equalTo(wordLanes.snp.leading)
            $0.trailing.equalTo(view.snp.centerX).offset(-5) //
        }
        
        missedWordsLabel.snp.makeConstraints {
            $0.top.equalTo(capturedWordsLabel)
            $0.leading.equalTo(view.snp.centerX).offset(5) //
            $0.trailing.equalToSuperview().inset(10)
        }
        
        capturedWordsBox.snp.makeConstraints {
            $0.top.equalTo(capturedWordsLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(capturedWordsLabel)
        }
        
        missedWordsBox.snp.makeConstraints {
            $0.top.bottom.equalTo(capturedWordsBox)
            $0.leading.trailing.equalTo(missedWordsLabel)
        }
        
        startButton.snp.makeConstraints {
            $0.top.equalTo(capturedWordsBox.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalTo(view.snp.centerX).offset(-5)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(10)
        }
        
        resetButton.snp.makeConstraints {
            $0.top.equalTo(startButton.snp.top)
            $0.leading.equalTo(view.snp.centerX).offset(5)
            $0.trailing.equalToSuperview().inset(10)
            $0.bottom.equalTo(startButton.snp.bottom)
        }
        
        // set up subviews of `wordLanes`
        // (!) wordViews constraints - inside `remakeWordViews(of:)`
        
        // set up wordsContent UIStackView
        capturedWordsContent.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }
        missedWordsContent.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    /// (Re)makes constraints of `WordView`s
    private func remakeWordViews(of words: [Word]) {
        words.forEach { word in
            guard let wordView = wordsWithWordViews[word.text] else { return }
//            wordView.layer.removeAllAnimations()
            
            wordView.snp.remakeConstraints {
                $0.top.equalToSuperview().offset(word.topOffset)
                $0.leading.equalToSuperview()
                $0.height.equalTo(30)
            }
            
            wordView.isHidden = false
        }
    }
}

// MARK: - Animations
extension ViewController {
    
    private func setupAnimation(of word: Word) -> UIViewPropertyAnimator? {
        
//        let duration = Double.random(in: 0.5...2.5)
        let duration = Double.random(in: 3.5...3.5)
        let animator = UIViewPropertyAnimator(duration: duration, curve: .linear, animations: {  [weak self] in
            guard let self = self else { return }
            guard let wordView = wordsWithWordViews[word.text] else { return }
            wordView.snp.remakeConstraints {
                $0.top.equalTo(word.topOffset)
                $0.trailing.equalToSuperview()
            }
            wordView.superview?.layoutIfNeeded() // apply the updated layout immediately
        })

        animator.addCompletion { [weak self] (position: UIViewAnimatingPosition) in
            guard let self = self else { return }
            switch position {
            case .end:
                self.reactor?.action.onNext(.missed(word)) // emits `.missed` after the animation is ended
            default:
                break
            }
        }
        
        return animator
    }
    
    private func startAnimations(of words: [Word]) {
        words.forEach { word in
            wordsWithAnimators[word.text] = setupAnimation(of: word)
            DispatchQueue.main.async { [weak self] in // start animation(UI) on a main thread
                self?.wordsWithAnimators[word.text]?.startAnimation()
            }
        }
    }
    
    private func stopAnimation(of wordText: String) {
        guard let wordView = wordsWithWordViews[wordText] else { return }
        
        wordsWithAnimators[wordText]?.stopAnimation(true) // stop animation and change state to [inactive]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // 레이어나 뷰의 동기화 문제, 애니메이션이 끝날 때까지 상태 안정화 보장 등을 고려한 완전한 초기화를 위해 0.2 대기
            wordView.layer.removeAllAnimations()

        }
    }
    
}

// MARK: - TapGesture, isUserInteractionEnabled
extension ViewController {
    private func setupTapGesture(to wordView: UIView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(captureWord(_:)))
        wordView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func captureWord(_ gesture: UITapGestureRecognizer) {
        guard let tappedWordView = gesture.view as? WordView else { return }

        // 1. Stop animation
        stopAnimation(of: tappedWordView.text)
        
        // 2. Manage views - hide from its superview
        tappedWordView.isHidden = true
        
        // 3. Emit an action `captured`
        reactor?.action.onNext(.captured(tappedWordView.text))
    }
    
    private func enableInteraction(for word: Word, isEnabled: Bool) {
        wordsWithWordViews[word.text]?.isUserInteractionEnabled = isEnabled
    }
    
    private func enableInteractionForAllWords(isEnabled: Bool) {
        wordsWithWordViews.values
            .forEach { $0.isUserInteractionEnabled = isEnabled }
    }
    
}

// MARK: - Reactor Binding
extension ViewController {
    func bind(reactor: ViewReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
    
    private func bindAction(_ reactor: ViewReactor) {

        startButton.rx.tap
            .map { ViewReactor.Action.startButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        resetButton.rx.tap
            .map { ViewReactor.Action.resetButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
    }
    
    private func bindState(_ reactor: ViewReactor) {
        reactor.state
            .map { $0.gameState }
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { (owner: ViewController, state: GameState) in
                print(state)
                switch state {
                case .initial:
                    // TODO: .initial(words)
                    owner.remakeWordViews(of: owner.initialWords)
                    owner.enableInteractionForAllWords(isEnabled: false)
                    owner.resetWordsBox(captured: true, missed: true)
                    
                case let .startAll(words):
                    owner.startAnimations(of: words)
                    words.forEach {
                        owner.enableInteraction(for: $0, isEnabled: true)
                    }
                    
                case let .start(word):
                    owner.startAnimations(of: [word])
                    owner.enableInteraction(for: word, isEnabled: true)
                    
                case let .emptyBoxes(words):
//                    words.forEach {
//                        self.wordsWithAnimators[$0.text]?.stopAnimation(true) // 애니메이션 강제 중지
//                        self.wordsWithAnimators[$0.text]?.finishAnimation(at: .start) // 초기 상태로 복귀
//                        self.wordsWithAnimators[$0.text] = nil
//
//                    }
                    
                    // 1. Empty captured words box
                    owner.resetWordsBox(captured: true, missed: true)
                    
                    // 2. Remake wordViews
                    owner.remakeWordViews(of: words)
                    
                default: break
                }
            }).disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.newMissedWord }
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { owner, word in
                owner.addMissedWord(word.text)
                owner.enableInteraction(for: word, isEnabled: false)
            }).disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.newCapturedWord }
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { owner, word in
                owner.addCapturedWord(word.text)
                owner.enableInteraction(for: word, isEnabled: false)
            }).disposed(by: disposeBag)
    }
}


// MARK: - Manage boxes
extension ViewController {
    private func resetWordsBox(captured: Bool, missed: Bool) {
        if captured == true,
           !capturedWordsContent.arrangedSubviews.isEmpty {
            capturedWordsContent.arrangedSubviews.forEach {
                capturedWordsContent.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
        }
        if missed == true,
           !missedWordsContent.arrangedSubviews.isEmpty {
            missedWordsContent.arrangedSubviews.forEach {
                missedWordsContent.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
        }
    }
    
    private func addCapturedWord(_ word: String) {
        let label = UILabel().then {
            $0.text = word
        }
        
        capturedWordsContent.addArrangedSubview(label)
    }
    private func addMissedWord(_ word: String) {
        let label = UILabel().then {
            $0.text = word
        }
        
        missedWordsContent.addArrangedSubview(label)
    }

}
