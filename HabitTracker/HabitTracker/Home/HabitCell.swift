//
//  HabitCell.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 14/06/2023.
//

import UIKit

class HabitCell: UITableViewCell {

    static let reuseID = "HabitCell"

    let nameLabel = UILabel()
    let completionLabel = UILabel()
    let infoStackView = UIStackView()

    let doneButton = UIButton()
    let buttonHeight: CGFloat = 30
    var buttonAction: (() -> Void)?
    let tickImageView = UIImageView(image: UIImage(systemName: "checkmark"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.numberOfLines = 0
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)

        completionLabel.translatesAutoresizingMaskIntoConstraints = false
        completionLabel.font = .systemFont(ofSize: 12)

        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        infoStackView.axis = .vertical
        infoStackView.spacing = 6

        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.black, for: .normal)
        doneButton.backgroundColor = .systemGray4
        doneButton.layer.cornerRadius = buttonHeight * 0.5
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)

        tickImageView.translatesAutoresizingMaskIntoConstraints = false
        tickImageView.isHidden = true
        tickImageView.contentMode = .scaleAspectFill
        tickImageView.tintColor = .systemGray2
    }

    private func layout() {
        infoStackView.addArrangedSubview(nameLabel)
        infoStackView.addArrangedSubview(completionLabel)
        contentView.addSubview(infoStackView)
        contentView.addSubview(doneButton)
        contentView.addSubview(tickImageView)

        NSLayoutConstraint.activate([
            infoStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            infoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            infoStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            infoStackView.trailingAnchor.constraint(equalTo: doneButton.leadingAnchor, constant: -8),

            doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            doneButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            doneButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1/4),
            doneButton.heightAnchor.constraint(equalToConstant: buttonHeight),

            tickImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            tickImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            tickImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    @objc func doneButtonTapped(sender: UIButton) {
        buttonAction?()
    }

    func configure(name: String, target: Int, current: Int) {
        var completionText = "\(current)/\(target) time"
        if target > 1 {
            completionText += "s"
        }
        completionLabel.text = completionText
        nameLabel.text = name
    }

    func styleAsCompleted() {
        doneButton.isHidden = true
        tickImageView.isHidden = false

        contentView.backgroundColor = .systemGray5
        nameLabel.textColor = .systemGray
        completionLabel.textColor = .systemGray
    }
}
