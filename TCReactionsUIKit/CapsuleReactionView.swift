//
//  CapsuleReactionView.swift
//  TCReactionsUIKit
//
//  Created by Fredy Sanchez on 16/05/23.
//

import UIKit

protocol CapsuleReactionViewDelegate: NSObject {
    func capsuleReactionView(_ capsuleReactionView: CapsuleReactionView, didSelectIndex index: Int, withValue value: String)
}

class CapsuleReactionView: UIView {
    private lazy var emojiStackView: UIStackView = {
        let emojiStackView = UIStackView()
        emojiStackView.axis = .horizontal
        emojiStackView.alignment = .center
        emojiStackView.distribution = .fillProportionally
        emojiStackView.backgroundColor = .gray
        emojiStackView.layer.cornerRadius = self.bounds.height / 2
        emojiStackView.layoutMargins = UIEdgeInsets(
            top: 0,
            left: self.bounds.width * 0.05,
            bottom: 0,
            right: self.bounds.width * 0.05
        )
        emojiStackView.isLayoutMarginsRelativeArrangement = true
        return emojiStackView
    }()
    
    /// Delegate that implements functionality of reaction buttons when pressed.
    weak var delegate: CapsuleReactionViewDelegate?
    
    /// Show the accessory button (last button) at the reaction capsule. The button will have a different action than the rest of the emoji reaction buttons.
    var shouldShowAccesoryButton: Bool = false {
        didSet {
            emojiStackView.arrangedSubviews.last?.isHidden = !shouldShowAccesoryButton
        }
    }
    
    /// The title for the accessory button (last button) in the reaction capsule.
    var accessoryButtonTitle: String = "+" {
        didSet {
            guard let accessoryButton = emojiStackView.arrangedSubviews.last as? UIButton else { return }
            accessoryButton.setTitle(accessoryButtonTitle, for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) not implemented!")
    }
    
    /// Setup the UI Elements
    private func setupUI() {
        let accessoryButton = createEmojiReactionButton(with: accessoryButtonTitle)
        emojiStackView.addArrangedSubview(accessoryButton)
        emojiStackView.arrangedSubviews.last?.isHidden = !shouldShowAccesoryButton
        self.addSubview(emojiStackView)
        setupConstraints()
    }
    
    /// Create a reaction button.
    /// - Parameter title: Title for the reaction button
    /// - Returns: Reaction button of type UIButton
    private func createEmojiReactionButton(with title: String) -> UIButton {
        let emojiButton = UIButton()
        emojiButton.setTitle(title, for: .normal)
        emojiButton.titleLabel?.font = UIFont.systemFont(ofSize: self.bounds.height / 2)
        emojiButton.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                let index = self.emojiStackView.arrangedSubviews.count
                self.delegate?.capsuleReactionView(self, didSelectIndex: index, withValue: title)
            },
            for: .touchUpInside
        )
        return emojiButton
    }
    
    /// Setup AutoLayout constraints.
    private func setupConstraints() {
        emojiStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            emojiStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            emojiStackView.topAnchor.constraint(equalTo: self.topAnchor),
            emojiStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    /// Append reaction buttons to the existing buttons in the reactions capsule.
    /// - Parameter titles: titles for the buttons to append.
    private func appendButtonToStackView(titles: [String]) {
        titles
            .map(createEmojiReactionButton(with:))
            .forEach { view in
                let indexOfAccessoryButton = emojiStackView.arrangedSubviews.count - 1
                emojiStackView.insertArrangedSubview(view, at: indexOfAccessoryButton)
            }
    }
    
    /// Clear the view for reuse.
    func prepareForReuse() {
        delegate = nil
        emojiStackView.removeAllSubviews()
    }
    
    /// Set the reaction button titles. CapusleReactionView only allows for 6 different titles, as the 7th element is reserved for the accessory button.
    /// - Parameter titles: Titles for the reactions buttons at the CapsuleReactionView.
    func setReaction(buttons titles: String...) {
        guard emojiStackView.arrangedSubviews.count <= 6
              || emojiStackView.arrangedSubviews.count + titles.count <= 6
        else {
            // TODO: do something more useful
            fatalError("Max amount of emojis reached")
        }
        
        appendButtonToStackView(titles: titles)
    }
    
    /// Update the title of the reaction button at the given index.
    /// - Parameters:
    ///   - index: index of the UIButton to update.
    ///   - title: new title for the UIButton at the given index.
    func updateTitle(for index: Int, title: String) {
        guard index < emojiStackView.arrangedSubviews.count else {
            // TODO: Do something
            fatalError("Index is out of bounds")
        }
        
        let buttons = emojiStackView
            .arrangedSubviews
            .compactMap { $0 as? UIButton }
        
        buttons[index].setTitle(title, for: .normal)
    }
}

extension UIStackView {
    func removeAllSubviews() {
        self.arrangedSubviews.forEach(self.removeArrangedSubview(_:))
    }
}
