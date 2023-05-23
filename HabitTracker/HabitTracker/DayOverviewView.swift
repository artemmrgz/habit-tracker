//
//  DayOverviewView.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 23/05/2023.
//

import UIKit

class DayOverviewView: UIView {
    let dateLabel = UILabel()
    let successLabel = UILabel()
    let failLabel = UILabel()
    let successHabitsStackView = UIStackView()
    let failHabitsStackView = UIStackView()
    
    let successView = UIView()
    let failView = UIView()
    
    let habitLabel = UILabel()
    
    
    let successHabits = ["Habit 1", "Habit 2"]
    let failHabits = ["Habit fail 1", "Habit fail 2"]
    
    let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.height * 0.17
    }
    
    private func getHabitLabel(title: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18)
        return label
    }
    
    private func style() {
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .systemFont(ofSize: 18)
        dateLabel.textAlignment = .center
        dateLabel.numberOfLines = 0
        dateLabel.text = "Data Label"
        
        successLabel.translatesAutoresizingMaskIntoConstraints = false
        successLabel.font = .systemFont(ofSize: 20, weight: .bold)
        successLabel.numberOfLines = 0
        successLabel.text = "Success"
        
        successHabitsStackView.translatesAutoresizingMaskIntoConstraints = false
        successHabitsStackView.axis = .vertical
        successHabitsStackView.spacing = 8
        successView.translatesAutoresizingMaskIntoConstraints = false
        
        failLabel.translatesAutoresizingMaskIntoConstraints = false
        failLabel.font = .systemFont(ofSize: 20, weight: .bold)
        failLabel.numberOfLines = 0
        failLabel.text = "Fail"
        
        failHabitsStackView.translatesAutoresizingMaskIntoConstraints = false
        failHabitsStackView.axis = .vertical
        failHabitsStackView.spacing = 8
        failView.translatesAutoresizingMaskIntoConstraints = false
        
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
    }
    
    private func layout() {
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(successLabel)
        
        for habit in successHabits {
            
            let habitLabel = getHabitLabel(title: habit)
            successHabitsStackView.addArrangedSubview(habitLabel)
            
            successView.addSubview(successHabitsStackView)
            stackView.addArrangedSubview(successView)
        }
        
        stackView.addArrangedSubview(failLabel)
        
        for habit in failHabits {
            
            let habitLabel = getHabitLabel(title: habit)
            failHabitsStackView.addArrangedSubview(habitLabel)
            
            failView.addSubview(failHabitsStackView)
            stackView.addArrangedSubview(failView)
        }
        
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            successHabitsStackView.leadingAnchor.constraint(equalTo: successView.leadingAnchor, constant: 16),
            successHabitsStackView.trailingAnchor.constraint(equalTo: successView.trailingAnchor, constant: -16),
            successHabitsStackView.topAnchor.constraint(equalTo: successView.topAnchor),
            successHabitsStackView.bottomAnchor.constraint(equalTo: successView.bottomAnchor),
            
            failHabitsStackView.leadingAnchor.constraint(equalTo: successHabitsStackView.leadingAnchor),
            failHabitsStackView.trailingAnchor.constraint(equalTo: successHabitsStackView.trailingAnchor),
            failHabitsStackView.topAnchor.constraint(equalTo: failView.topAnchor),
            failHabitsStackView.bottomAnchor.constraint(equalTo: failView.bottomAnchor),
        ])
    }
    
    func configureWith(date: String) {
        dateLabel.text = date
    }
    
    
}
