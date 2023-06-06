//
//  HomeViewController.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 22/05/2023.
//

import UIKit

class HomeViewController: UIViewController {

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let dayOverviewView = DayOverviewView()

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

        dayOverviewView.translatesAutoresizingMaskIntoConstraints = false
        dayOverviewView.backgroundColor = .systemGray3
        dayOverviewView.isHidden = true
        dayOverviewView.alpha = 0

        view.addSubview(collectionView)
        view.addSubview(nameLabel)
        view.addSubview(dayOverviewView)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),

            collectionView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            collectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1),

            dayOverviewView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dayOverviewView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            dayOverviewView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
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

    private func getCellFrame(from collectionView: UICollectionView, at indexPath: IndexPath) -> CGRect? {
        let attribures = collectionView.layoutAttributesForItem(at: indexPath)
        guard let attribures = attribures else { return nil }
        let cellFrame = collectionView.convert(attribures.frame, to: collectionView.superview)
        return cellFrame
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard !calendarViewModel.sevenDays.isEmpty,
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCell.reuseID,
                                                            for: indexPath) as? CalendarCell else {
            return UICollectionViewCell() }

        let day = calendarViewModel.sevenDays[indexPath.row]

        cell.configureWith(dayOfMonth: day.dayOfMonth,
                           dayOfWeek: day.dayOfWeek,
                           isToday: calendarViewModel.dateToday == day.dayAsDate)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !calendarViewModel.sevenDays.isEmpty else { return }
        guard let cellFrame = getCellFrame(from: collectionView, at: indexPath) else { return }

        let day = calendarViewModel.sevenDays[indexPath.row]

        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let date = formatter.string(from: day.dayAsDate)

        dayOverviewView.configureWith(date: date)

        let initialFrame = dayOverviewView.frame
        dayOverviewView.frame = cellFrame
        dayOverviewView.stackView.alpha = 0

        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5) {
            self.dayOverviewView.isHidden = false
            self.dayOverviewView.alpha = 1
            self.dayOverviewView.frame = initialFrame
        }

        UIView.animate(withDuration: 0.4, delay: 0.4, usingSpringWithDamping: 0.8, initialSpringVelocity: 5) {
            self.dayOverviewView.stackView.alpha = 1
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 7 - 5
        return CGSize(width: width, height: collectionView.bounds.size.height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}
