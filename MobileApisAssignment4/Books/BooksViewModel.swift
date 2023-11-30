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
    func insertRows(at indexPaths: [IndexPath])
    func reloadRows(at indexPaths: [IndexPath])
    func scroll(to indexPath: IndexPath, at position: UITableView.ScrollPosition)
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
        showBookCRUDScreen()
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> BookCellViewModelable? {
        guard let book = books[safe: indexPath.row] else { return nil }
        return BookCellViewModel(book: book)
    }
    
    func didSelectBook(at indexPath: IndexPath) {
        guard let book = books[safe: indexPath.row] else { return }
        showBookCRUDScreen(with: book.id)
    }
    
}

// MARK: - Private Helpers
private extension BooksViewModel {
    
    func fetchBooks() {
        presenter?.startLoading()
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
    
    func showBookCRUDScreen(with bookId: String? = nil) {
        let viewModel = BookCRUDViewModel(
            bookId: bookId,
            authToken: authToken,
            listener: self
        )
        let viewController = BookCRUDViewController.loadFromStoryboard()
        viewController.viewModel = viewModel
        viewModel.presenter = viewController
        presenter?.push(viewController)
    }
    
    func scroll(to indexPath: IndexPath, at position: UITableView.ScrollPosition) {
        DispatchQueue.main.async { [weak self] in
            self?.presenter?.scroll(to: indexPath, at: position)
        }
    }
    
}

// MARK: - BookCRUDViewModelListener Methods
extension BooksViewModel: BookCRUDViewModelListener {
    
    func add(book: Book) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.delayDuration) { [weak self] in
            guard let self = self else { return }
            books.append(book)
            let indexPath = IndexPath(row: books.count - 1, section: 0)
            presenter?.insertRows(at: [indexPath])
            scroll(to: indexPath, at: .bottom)
        }
    }
    
    func update(book: Book) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.delayDuration) { [weak self] in
            guard let self = self,
                  let index = books.firstIndex(where: { $0.id == book.id }) else { return }
            books[index] = book
            let indexPath = IndexPath(row: index, section: 0)
            presenter?.reloadRows(at: [indexPath])
            scroll(to: indexPath, at: .middle)
        }
    }
    
}
