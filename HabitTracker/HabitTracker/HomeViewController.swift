//
//  HomeViewController.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 22/05/2023.
//

import UIKit

class HomeViewController: UIViewController {

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let calendarViewModel = CalendarViewModel()
    let nameLabel = UILabel()
    
    override func viewDidLoad() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: CalendarCell.reuseID)
        
        view.backgroundColor = .systemBackground
        
        layout()
        performGesture()
    }
    
    func layout() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Hello"
        nameLabel.font = .systemFont(ofSize: 30)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            
            collectionView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            collectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1)
        ])
    }
    
    private func performGesture() {
        let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        
        leftGesture.direction = .left
        rightGesture.direction = .right
        
        collectionView.addGestureRecognizer(leftGesture)
        collectionView.addGestureRecognizer(rightGesture)
    }
    
    @objc func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            calendarViewModel.getPreviousSevenDays()
            collectionView.layer.add(swipeTransition(isRight: true), forKey: nil)
            collectionView.reloadData()
            
        }
        
        if sender.direction == .left {
            if calendarViewModel.getNextSevenDays() {
                collectionView.layer.add(swipeTransition(isRight: false), forKey: nil)
                collectionView.reloadData()
            }
        }
    }
    
    private func swipeTransition(isRight: Bool) -> CATransition {
        let transition = CATransition()
        transition.type = .push
        transition.duration = 0.4
        transition.subtype = isRight ? .fromLeft : .fromRight
        
        return transition
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard !calendarViewModel.sevenDays.isEmpty else { return UICollectionViewCell() }
        let day = calendarViewModel.sevenDays[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCell.reuseID, for: indexPath) as! CalendarCell
        cell.configureWith(dayOfMonth: day.dayOfMonth, dayOfWeek: day.dayOfWeek, isToday: calendarViewModel.dateToday == day.dayAsDate)
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 7 - 5
        return CGSize(width: width, height: collectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

