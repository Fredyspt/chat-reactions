//
//  TableViewCell.swift
//  TCReactionsUIKit
//
//  Created by Fredy Sanchez on 15/05/23.
//

import UIKit

class MessageBubbleCell: UITableViewCell {
    
    static let identifier = "MessageBubbleCell"

    private lazy var bubble: UIView = {
        let bubble = UIView()
        bubble.backgroundColor = .systemGreen
        bubble.layer.cornerRadius = 5.0
        return bubble
    }()
    
    private lazy var message: UILabel = {
        let message = UILabel()
        message.font = UIFont.systemFont(ofSize: 14)
        return message
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.contentView.addSubview(bubble)
        self.contentView.addSubview(message)
        
        bubble.translatesAutoresizingMaskIntoConstraints = false
        message.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            message.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 4),
            message.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -4),
            message.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 4),
            message.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -4),
            bubble.heightAnchor.constraint(equalToConstant: 50),
            bubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            bubble.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            bubble.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15)
        ])
    }
    
    func configure(with message: String) {
        self.message.text = message
    }
}
