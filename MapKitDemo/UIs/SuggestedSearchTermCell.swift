//
//  SuggestedSearchTermCell.swift
//  MapKitDemo
//
//  Created by Chiaote Ni on 2023/5/28.
//

import UIKit

final class SuggestedSearchTermCell: UITableViewCell {

    private let label = UILabel()
    private let backboardView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        backgroundColor = .clear

        backboardView
            .add(to: contentView)
            .anchor(\.centerYAnchor, to: contentView.centerYAnchor)
            .anchor(\.heightAnchor, to: contentView.heightAnchor, multiplier: 0.9)
            .anchor(\.leadingAnchor, to: contentView.leadingAnchor)
            .anchor(\.trailingAnchor, to: contentView.trailingAnchor)
        backboardView
            .set(\.backgroundColor, with: UIColor.systemGray6.withAlphaComponent(0.8))
            .set(\.layer.cornerRadius, with: 8)
            .set(\.layer.masksToBounds, with: true)
        
        label
            .add(to: contentView)
            .anchor(\.centerYAnchor, to: contentView.layoutMarginsGuide.centerYAnchor)
            .anchor(\.leadingAnchor, to: contentView.layoutMarginsGuide.leadingAnchor)
            .anchor(\.trailingAnchor, to: contentView.layoutMarginsGuide.trailingAnchor)
        label
            .set(\.font, with: .systemFont(ofSize: 16))
            .set(\.numberOfLines, with: 0)
            .set(\.textColor, with: .darkGray)
            .set(\.textAlignment, with: .left)
            .set(\.lineBreakMode, with: .byWordWrapping)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with text: String) {
        label.text = text
    }
}
