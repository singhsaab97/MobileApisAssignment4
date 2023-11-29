//
//  BooksViewController.swift
//  MobileApisAssignment4
//
//  Created by Abhijit Singh on 15/11/23.
//

import UIKit

final class BooksViewController: UIViewController,
                                 ViewLoadable {
    
    static let name = Constants.storyboardName
    static let identifier = Constants.booksViewController
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var spinnerView: UIActivityIndicatorView!
    
    var viewModel: BooksViewModelable?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

}

// MARK: - Private Helpers
private extension BooksViewController {
    
    func setup() {
        navigationItem.title = viewModel?.title
        addLogoutButton()
        addAddButton()
        BookTableViewCell.register(for: tableView)
        viewModel?.screenDidLoad()
    }
    
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
    
    func startLoading() {
        spinnerView.isHidden = false
        spinnerView.startAnimating()
    }
    
    func stopLoading() {
        spinnerView.stopAnimating()
        spinnerView.isHidden = true
    }
    
    func reloadSections(_ indexSet: IndexSet) {
        tableView.reloadSections(indexSet, with: .fade)
    }
    
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
