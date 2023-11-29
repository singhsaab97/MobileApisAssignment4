//
//  BookCRUDViewController.swift
//  MobileApisAssignment4
//
//  Created by Abhijit Singh on 27/11/23.
//

import UIKit

final class BookCRUDViewController: UIViewController,
                                    ViewLoadable {

    static let name = Constants.storyboardName
    static let identifier = Constants.bookCRUDViewController
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var spinnerView: UIActivityIndicatorView!
    
    var viewModel: BookCRUDViewModelable?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

}

// MARK: - Private Helpers
private extension BookCRUDViewController {
    
    func setup() {
        navigationItem.title = viewModel?.title
        viewModel?.screenDidLoad()
    }
    
}

// MARK: - UITableViewDelegate Methods
extension BookCRUDViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO
    }
    
}

// MARK: - UITableViewDataSource Methods
extension BookCRUDViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0 // TODO
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let viewModel = viewModel?.getCellViewModel(at: indexPath) else { return UITableViewCell() }
//        let bookCell = BookTableViewCell.dequeReusableCell(from: tableView, at: indexPath)
//        bookCell.configure(with: viewModel)
//        return bookCell
        return UITableViewCell() // TODO
    }
    
}

// MARK: - BooksViewModelPresenter Methods
//extension BookCRUDViewController: BooksViewModelPresenter {
//
//    func setNavigationTitle(_ title: String) {
//        navigationItem.title = title
//    }
//
//    func startLoading() {
//        spinnerView.isHidden = false
//        spinnerView.startAnimating()
//    }
//
//    func stopLoading() {
//        spinnerView.stopAnimating()
//        spinnerView.isHidden = true
//    }
//
//    func reloadSections(_ indexSet: IndexSet) {
//        tableView.reloadSections(indexSet, with: .fade)
//    }
//
//    func present(_ viewController: UIViewController) {
//        navigationController?.present(viewController, animated: true)
//    }
//
//    func dismiss() {
//        navigationController?.dismiss(animated: true)
//    }
//
//}
