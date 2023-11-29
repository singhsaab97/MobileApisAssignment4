//
//  BooksViewModel.swift
//  MobileApisAssignment4
//
//  Created by Abhijit Singh on 15/11/23.
//

import UIKit

protocol BooksViewModelListener: AnyObject {
    func userLoggingOut()
}

protocol BooksViewModelPresenter: AnyObject {
    func startLoading()
    func stopLoading()
    func reloadSections(_ sections: IndexSet)
    func push(_ viewController: UIViewController)
    func present(_ viewController: UIViewController)
    func dismiss()
}

protocol BooksViewModelable {
    var title: String { get }
    var logoutButtonImage: UIImage? { get }
    var addButtonImage: UIImage? { get }
    var numberOfBooks: Int { get }
    var presenter: BooksViewModelPresenter? { get set }
    func screenDidLoad()
    func logoutButtonTapped()
    func addButtonTapped()
    func getCellViewModel(at indexPath: IndexPath) -> BookCellViewModelable?
    func didSelectBook(at indexPath: IndexPath)
}

final class BooksViewModel: BooksViewModelable,
                            Toastable {
    

    private let authToken: String
    private var books: [Book]
    
    private weak var listener: BooksViewModelListener?
    
    weak var presenter: BooksViewModelPresenter?
    
    init(authToken: String, listener: BooksViewModelListener?) {
        self.authToken = authToken
        self.books = []
        self.listener = listener
    }
    
}

// MARK: - Exposed Helpers
extension BooksViewModel {
    
    var title: String {
        return Constants.books
    }
    
    var logoutButtonImage: UIImage? {
        return UIImage(systemName: "arrowshape.turn.up.backward")
    }
    
    var addButtonImage: UIImage? {
        return UIImage(systemName: "plus")
    }
    
    var numberOfBooks: Int {
        return books.count
    }
    
    func screenDidLoad() {
        fetchBooks()
    }
    
    func logoutButtonTapped() {
        let alertController = UIAlertController(
            title: Constants.logoutAlertTitle,
            message: Constants.logoutAlertMessage,
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(
            title: Constants.alertCancelTitle,
            style: .default
        )
        let logoutAction = UIAlertAction(
            title: Constants.logoutAlertLogoutTitle,
            style: .destructive
        ) { [weak self] _ in
            self?.listener?.userLoggingOut()
            self?.presenter?.dismiss()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(logoutAction)
        presenter?.present(alertController)
    }
    
    func addButtonTapped() {
        showBookCRUDScreen(for: nil)
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> BookCellViewModelable? {
        guard let book = books[safe: indexPath.row] else { return nil }
        return BookCellViewModel(book: book)
    }
    
    func didSelectBook(at indexPath: IndexPath) {
        guard let book = books[safe: indexPath.row] else { return }
        showBookCRUDScreen(for: book)
    }
    
}

// MARK: - Private Helpers
private extension BooksViewModel {
    
    func fetchBooks() {
        DataHandler.shared.fetchBooks(with: authToken) { result in
            DispatchQueue.main.async { [weak self] in
                self?.presenter?.stopLoading()
                switch result {
                case let .success(data):
                    guard let books = try? JSONDecoder().decode([Book].self, from: data) else { return }
                    self?.books = books
                    self?.presenter?.reloadSections(IndexSet(integer: 0))
                case let .failure(error):
                    self?.showToast(with: error.localizedDescription)
                }
            }
        }
    }
    
    func showBookCRUDScreen(for book: Book?) {
        let viewModel = BookCRUDViewModel(book: book)
        let viewController = BookCRUDViewController.loadFromStoryboard()
        viewController.viewModel = viewModel
        presenter?.push(viewController)
    }
    
}
