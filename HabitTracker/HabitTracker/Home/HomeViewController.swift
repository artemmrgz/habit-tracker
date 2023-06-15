//
//  HomeViewController.swift
//  HabitTracker
//
//  Created by Artem Marhaza on 22/05/2023.
//

import UIKit

class HomeViewController: UIViewController {

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    let tableView = UITableView(frame: .zero, style: .grouped)

    let addHabitButton = UIButton()
    var spinner = UIActivityIndicatorView(style: .medium)

    let calendarVM = CalendarViewModel()
    let habitsVM = HabitsViewModel()

    var currentSelectedIndex = IndexPath(row: 0, section: 0)
    var previousSelectedIndex = IndexPath(row: 0, section: 0)

    override func viewDidLoad() {
        title = "Home"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground

        setupCollectionView()
        setupTableView()
        setupButton()
        setupSpinner()
        setupBinders()

        currentSelectedIndex = IndexPath(row: calendarVM.days.count - 1, section: 0)
        collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: currentSelectedIndex)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let indexPath = IndexPath(row: calendarVM.days.count - 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: CalendarCell.reuseID)

        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            collectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1)
        ])
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HabitCell.self, forCellReuseIdentifier: HabitCell.reuseID)
        tableView.register(TableHeader.self, forHeaderFooterViewReuseIdentifier: TableHeader.reuseID)
        tableView.sectionFooterHeight = 0

        tableView.backgroundColor = .systemBackground
        tableView.setContentHuggingPriority(.defaultLow, for: .vertical)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16)
        ])
    }

    private func setupButton() {
        addHabitButton.setTitle("Add Habit", for: .normal)
        addHabitButton.backgroundColor = .systemPurple
        addHabitButton.setTitleColor(.black, for: .normal)
        addHabitButton.layer.cornerRadius = 60 * 0.17
        addHabitButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
        addHabitButton.addTarget(self, action: #selector(addHabitTapped), for: .touchUpInside)
        addHabitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addHabitButton)

        NSLayoutConstraint.activate([
            addHabitButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 8),
            addHabitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addHabitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            addHabitButton.heightAnchor.constraint(equalToConstant: 60),
            addHabitButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/3)
        ])
    }

    private func setupSpinner() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        tableView.addSubview(spinner)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }

    private func setupBinders() {
        habitsVM.error.bind { errorAlert in
            guard let errorAlert else { return }
            self.present(errorAlert, animated: true)
        }
    }

    @objc func addHabitTapped() {
        // TODO: show new screen for adding a new habit
    }

    private func resetTableView() {
        habitsVM.activeHabits.removeAll()
        habitsVM.completedHabits.removeAll()
        habitsVM.error.value = nil
        tableView.reloadData()

        spinner.startAnimating()
        spinner.isHidden = false
    }
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calendarVM.days.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard !calendarVM.days.isEmpty,
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCell.reuseID,
                                                            for: indexPath) as? CalendarCell else {
            return UICollectionViewCell() }

        let day = calendarVM.days[indexPath.row]

        cell.configureWith(dayOfMonth: day.dayOfMonth, dayOfWeek: day.dayOfWeek)

        if currentSelectedIndex == indexPath {
            cell.contentView.backgroundColor = .systemPurple
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !calendarVM.days.isEmpty else { return }
        let day = calendarVM.days[indexPath.row]

        previousSelectedIndex = currentSelectedIndex
        currentSelectedIndex = indexPath
        collectionView.reloadItems(at: [currentSelectedIndex])
        collectionView.reloadItems(at: [previousSelectedIndex])

        resetTableView()

        habitsVM.getHabits(forDate: day.dayAsDate) { [weak self] in
            self?.spinner.isHidden = true
            self?.spinner.stopAnimating()
            self?.tableView.reloadData()
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
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 {
            return habitsVM.activeHabits.count
        } else if section == 1 {
            return habitsVM.failedHabits.count
        } else {
            return habitsVM.completedHabits.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HabitCell.reuseID, for: indexPath)
                as? HabitCell else { return UITableViewCell() }

        let dataSource: [Habit]

        if indexPath.section == 0 {
            dataSource = habitsVM.activeHabits
        } else if indexPath.section == 1 {
            dataSource = habitsVM.failedHabits
        } else {
            dataSource = habitsVM.completedHabits
            cell.styleAsCompleted()
        }
        let habit = dataSource[indexPath.row]
        let completionDataTarget = habit.completionData.target
        var completionDataCurrent = habit.completionData.current
        cell.configure(name: habit.name, target: completionDataTarget, current: completionDataCurrent)

        cell.buttonAction = {
            completionDataCurrent += 1
            cell.configure(name: habit.name, target: habit.completionData.target, current: completionDataCurrent)
            if completionDataCurrent == completionDataTarget && indexPath.section == 0 {
                let index = IndexPath(row: self.habitsVM.completedHabits.count, section: 2)
                let habit = self.habitsVM.activeHabits.remove(at: indexPath.row)
                self.habitsVM.completedHabits.append(habit)
                tableView.performBatchUpdates {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    tableView.insertRows(at: [index], with: .automatic)
                }
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section > 0 else { return nil }

        var headerText: String?
        if section == 1 && !habitsVM.failedHabits.isEmpty {
            headerText = "Failed"
        } else if section == 2 && !habitsVM.completedHabits.isEmpty {
            headerText = "Completed"
        }

        guard let headerText else { return nil }

        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableHeader.reuseID) as? TableHeader
        header?.configure(text: headerText)
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let height: CGFloat = 40

        if section == 1 && !habitsVM.failedHabits.isEmpty {
            return height
        }
        if section == 2 && !habitsVM.completedHabits.isEmpty {
            return height
        }
        return 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: display habit details
    }
}
