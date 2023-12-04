//
//  BooksViewController.swift
//  MobileApisAssignment4
//
//  Created by Abhijit Singh on 15/11/23.
//

import UIKit

final class BooksViewController: UIViewController,
                                 ViewLoadable {
    
    // MARK: - Constants
    
    static let name = Constants.storyboardName
    static let identifier = Constants.booksViewController
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var spinnerView: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    var viewModel: BooksViewModelable?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
}

// MARK: - Private Helpers
private extension BooksViewController {
    
    // MARK: - Setup
    
    func setup() {
        navigationItem.title = viewModel?.title
        addLogoutButton()
        addAddButton()
        BookTableViewCell.register(for: tableView)
        viewModel?.screenDidLoad()
    }
    
    // MARK: - Navigation Bar Buttons
    
    func addLogoutButton() {
        let logoutButton = UIBarButtonItem(
            image: viewModel?.logoutButtonImage,
            style: .plain,
            target: self,
            action: #selector(logoutButtonTapped)
        )
        navigationItem.leftBarButtonItem = logoutButton
    }
    
    func addAddButton() {
        let addButton = UIBarButtonItem(
            image: viewModel?.addButtonImage,
            style: .plain,
            target: self,
            action: #selector(addButtonTapped)
        )
        navigationItem.rightBarButtonItem = addButton
    }
    
    // MARK: - Button Actions
    
    @objc
    func logoutButtonTapped() {
        viewModel?.logoutButtonTapped()
    }
    
    @objc
    func addButtonTapped() {
        viewModel?.addButtonTapped()
    }
    
}

// MARK: - UITableViewDelegate Methods
extension BooksViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel?.didSelectBook(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return viewModel?.trailingSwipedBook(at: indexPath)
    }
    
}

// MARK: - UITableViewDataSource Methods
extension BooksViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfBooks ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel?.getCellViewModel(at: indexPath) else { return UITableViewCell() }
        let bookCell = BookTableViewCell.dequeReusableCell(from: tableView, at: indexPath)
        bookCell.configure(with: viewModel)
        return bookCell
    }
    
}

// MARK: - BooksViewModelPresenter Methods
extension BooksViewController: BooksViewModelPresenter {
    
    // MARK: - Loading and Presentation
    
    func startLoading() {
        spinnerView.isHidden = false
        spinnerView.startAnimating()
    }
    
    func stopLoading() {
        spinnerView.stopAnimating()
        spinnerView.isHidden = true
    }
    
    // MARK: - Table View Updates
    
    func reloadSections(_ indexSet: IndexSet) {
        tableView.reloadSections(indexSet, with: .fade)
    }
    
    func insertRows(at indexPaths: [IndexPath]) {
        tableView.insertRows(at: indexPaths, with: .fade)
    }
    
    func reloadRows(at indexPaths: [IndexPath]) {
        tableView.reloadRows(at: indexPaths, with: .fade)
    }
    
    func deleteRows(at indexPaths: [IndexPath]) {
        tableView.deleteRows(at: indexPaths, with: .fade)
    }
    
    // MARK: - Table View Scrolling
    
    func scroll(to indexPath: IndexPath, at position: UITableView.ScrollPosition) {
        tableView.scrollToRow(at: indexPath, at: position, animated: true)
    }
    
    // MARK: - Navigation
    
    func push(_ viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func present(_ viewController: UIViewController) {
        navigationController?.present(viewController, animated: true)
    }
    
    func dismiss() {
        navigationController?.dismiss(animated: true)
    }
    
}
