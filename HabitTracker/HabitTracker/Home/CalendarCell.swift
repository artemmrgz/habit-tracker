//
//  CalendarCell.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 22/05/2023.
//

import UIKit

class CalendarCell: UICollectionViewCell {

    static let reuseID = "CalendarCell"

    let dayOfMonthLabel = UILabel()
    let dayOfWeekLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        style()
        layout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.layer.cornerRadius = contentView.bounds.width * 0.17
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func style() {
        contentView.backgroundColor = .systemGray

        dayOfMonthLabel.translatesAutoresizingMaskIntoConstraints = false
        dayOfMonthLabel.numberOfLines = 0
        dayOfMonthLabel.textAlignment = .center
        dayOfMonthLabel.font = .systemFont(ofSize: 15, weight: .bold)

        dayOfWeekLabel.translatesAutoresizingMaskIntoConstraints = false
        dayOfWeekLabel.numberOfLines = 0
        dayOfWeekLabel.textAlignment = .center
        dayOfWeekLabel.font = .systemFont(ofSize: 13)
    }

    private func layout() {
        contentView.addSubview(dayOfMonthLabel)
        contentView.addSubview(dayOfWeekLabel)

        NSLayoutConstraint.activate([
            dayOfMonthLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            dayOfMonthLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            dayOfWeekLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            dayOfWeekLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }

    func configureWith(dayOfMonth: String, dayOfWeek: String) {
        self.dayOfMonthLabel.text = dayOfMonth
        self.dayOfWeekLabel.text = dayOfWeek
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        contentView.backgroundColor = .systemGray
    }
}
