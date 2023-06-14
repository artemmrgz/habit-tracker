//
//  TableHeader.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 15/06/2023.
//

import UIKit

class TableHeader: UITableViewHeaderFooterView {
    static let reuseID = "TableHeader"

    private let label = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.sizeToFit()

        contentView.backgroundColor = .systemCyan
        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(text: String) {
        label.text = text
    }
}
