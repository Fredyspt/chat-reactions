//
//  ViewController.swift
//  TCReactionsUIKit
//
//  Created by Fredy Sanchez on 15/05/23.
//

import UIKit
import Combine

class ViewController: UIViewController {
    private var messages = [
        "Hello",
        "What's up?",
        "Hey",
        "Howdy",
        "Hey y'all",
    ]
    
    private var emojiPicker: CapsuleReactionView!
    var cancellable: AnyCancellable?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MessageBubbleCell.self, forCellReuseIdentifier: MessageBubbleCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageBubbleCell.identifier, for: indexPath) as? MessageBubbleCell else { return UITableViewCell() }
        cell.configure(with: messages[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let messageIdx = indexPath.row
        let message = messages[messageIdx]
        
        let identifier = indexPath as NSIndexPath
        
        return UIContextMenuConfiguration(
            identifier: identifier,
            previewProvider: nil,
            actionProvider: { _ in
                let resendAction = UIAction(
                    title: "Resend",
                    image: UIImage(systemName: "arrow.counterclockwise")
                ) { _ in
                    print("resend pressed!")
                }
                
                let resendAsPriorityAction = UIAction(
                    title: "Resend as Priority",
                    image: UIImage(systemName: "exclamationmark.arrow.circlepath")
                ) { _ in
                    print("resend pressed!")
                }
                
                let forwardAction = UIAction(
                    title: "Forward",
                    image: UIImage(systemName: "arrowshape.turn.up.right")
                ) { _ in
                    print("resend pressed!")
                }
                
                let detailsAction = UIAction(
                    title: "Details",
                    image: UIImage(systemName: "info.circle")
                ) { _ in
                    print("resend pressed!")
                }
                
                let recallAction = UIAction(
                    title: "Recall",
                    image: UIImage(systemName: "return"),
                    attributes: .destructive
                ) { _ in
                    print("recall pressed!")
                }
                
                
                return UIMenu(children: [resendAction, resendAsPriorityAction, forwardAction, detailsAction, recallAction])
            }
        )
    }
    
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let identifier = configuration.identifier as? IndexPath else { return nil }
        
        // 1. Get the cell that was pressed
        let index = identifier.row
        guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? MessageBubbleCell else {
            return nil
        }
        
        // 2. Create emoji picker capsule
        emojiPicker = CapsuleReactionView(frame: CGRect(
            origin: .zero,
            size: CGSize(
                width: 250,
                height: 50
            )
        ))
        
        emojiPicker.setReaction(buttons: "👏", "👍", "❤️")
        emojiPicker.shouldShowAccesoryButton = true
        emojiPicker.accessoryButtonTitle = "..."
        emojiPicker.isHidden = true
        emojiPicker.translatesAutoresizingMaskIntoConstraints = false
        
        let newEmojis = ["😂", "😮", "🎉"]
        cancellable = newEmojis
            .publisher
            .delay(for: 3.0, scheduler: DispatchQueue.main)
            .sink(receiveValue: { reactions in
                reactions.forEach {
                    self.emojiPicker.setReaction(buttons: String($0))
                }
            })
        
        // 3. Get snapshot of pressed cell
        guard let snapshot = cell.snapshotView(afterScreenUpdates: false) else { return nil }
        
        snapshot.isHidden = false
        snapshot.layer.cornerRadius = 10
        snapshot.layer.masksToBounds = true
        snapshot.translatesAutoresizingMaskIntoConstraints = false
        
        // 4. Create container for snapshot and emoji picker
        let container = UIView(frame: CGRect(
            origin: .zero,
            size: CGSize(
                width: cell.bounds.width,
                height: cell.bounds.height + emojiPicker.bounds.height + 5
            )
        ))
        container.backgroundColor = .clear
        container.addSubview(emojiPicker)
        container.addSubview(snapshot)
        
        // 4.1 Setup container constraints
        NSLayoutConstraint.activate([
            emojiPicker.topAnchor.constraint(equalTo: container.topAnchor),
            emojiPicker.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            emojiPicker.widthAnchor.constraint(equalToConstant: emojiPicker.bounds.width),
            emojiPicker.heightAnchor.constraint(equalToConstant: emojiPicker.bounds.height),
            snapshot.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            snapshot.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            snapshot.widthAnchor.constraint(equalToConstant: cell.bounds.width),
            snapshot.heightAnchor.constraint(equalToConstant: cell.bounds.height),
            container.widthAnchor.constraint(equalToConstant: cell.bounds.width),
        ])
        
        // 5. Calculate center to make sure snapshot in container is placed right on top of the actual cell
        let centerPoint = CGPoint(x: cell.center.x, y: cell.center.y - emojiPicker.bounds.height + 10)
        
        // 6. Setup preview target container and position
        let previewTarget = UIPreviewTarget(container: tableView, center: centerPoint)
        
        let previewParameters = UIPreviewParameters()
        previewParameters.backgroundColor = .clear
        previewParameters.shadowPath = UIBezierPath()
        
        return UITargetedPreview(view: container, parameters: previewParameters, target: previewTarget)
    }
    
    func tableView(_ tableView: UITableView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        animator?.addAnimations { [weak self] in
            self?.emojiPicker.isHidden = false
        }
    }
    
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.preferredCommitStyle = .dismiss
    }
}
