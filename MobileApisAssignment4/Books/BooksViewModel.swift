//
//  BooksViewModel.swift
//  MobileApisAssignment4
//
//  Created by Abhijit Singh on 15/11/23.
//

import UIKit

// Protocol for notifying when the user logs out
protocol BooksViewModelListener: AnyObject {
    func userLoggingOut()
}

// Protocol for presenting updates in the UI
protocol BooksViewModelPresenter: AnyObject {
    func startLoading()
    func stopLoading()
    func reloadSections(_ sections: IndexSet)
    func insertRows(at indexPaths: [IndexPath])
    func reloadRows(at indexPaths: [IndexPath])
    func deleteRows(at indexPaths: [IndexPath])
    func scroll(to indexPath: IndexPath, at position: UITableView.ScrollPosition)
    func push(_ viewController: UIViewController)
    func present(_ viewController: UIViewController)
    func dismiss()
}

// Protocol defining the requirements for the BooksViewModel
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
    func trailingSwipedBook(at indexPath: IndexPath) -> UISwipeActionsConfiguration
}

// Concrete implementation of the BooksViewModel
final class BooksViewModel: BooksViewModelable, Toastable {
    
    private let authToken: String
    private var books: [Book]
    
    private weak var listener: BooksViewModelListener?
    
    weak var presenter: BooksViewModelPresenter?
    
    // Initialization
    init(authToken: String, listener: BooksViewModelListener?) {
        self.authToken = authToken
        self.books = []
        self.listener = listener
    }
    
    // Computed properties and methods exposed to the view controller
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
    
    // Load books when the screen loads
    func screenDidLoad() {
        fetchBooks()
    }
    
    // Handle logout button tap
    func logoutButtonTapped() {
        // Display alert to confirm logout
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
    
    // Handle add button tap
    func addButtonTapped() {
        showBookCRUDScreen()
    }
    
    // Get the view model for a cell at a specific index path
    func getCellViewModel(at indexPath: IndexPath) -> BookCellViewModelable? {
        guard let book = books[safe: indexPath.row] else { return nil }
        return BookCellViewModel(book: book)
    }
    
    // Handle book selection
    func didSelectBook(at indexPath: IndexPath) {
        guard let book = books[safe: indexPath.row] else { return }
        showBookCRUDScreen(with: book.id)
    }
    
    // Provide swipe actions for a book cell
    func trailingSwipedBook(at indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let action = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, _) in
            guard let book = self?.books[safe: indexPath.row] else { return }
            self?.showDeleteAlert(for: book)
        }
        action.image = UIImage(systemName: "trash.fill")
        return UISwipeActionsConfiguration(actions: [action])
    }
}

// Extension for private helper methods
private extension BooksViewModel {
    
    // Fetch books from the server
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
    
    // Delete a book from the server
    func deleteBook(_ book: Book) {
        DataHandler.shared.deleteBook(with: book.id, authToken: authToken) { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success:
                    guard let index = self?.books.firstIndex(where: { $0.id == book.id }) else { return }
                    self?.books.remove(at: index)
                    let indexPath = IndexPath(row: index, section: 0)
                    self?.presenter?.deleteRows(at: [indexPath])
                case let .failure(error):
                    self?.showToast(with: error.localizedDescription)
                }
            }
        }
    }
    
    // Show the Book CRUD screen
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
    
    // Scroll to a specific indexPath in the table view
    func scroll(to indexPath: IndexPath, at position: UITableView.ScrollPosition) {
        presenter?.scroll(to: indexPath, at: position)
    }
    
    // Show delete confirmation alert
    func showDeleteAlert(for book: Book) {
        let alertController = UIAlertController(
            title: "\(Constants.delete) \"\(book.name)\"?",
            message: Constants.deleteAlertMessage,
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(
            title: Constants.alertCancelTitle,
            style: .default
        )
        let deleteAction = UIAlertAction(
            title: Constants.delete,
            style: .destructive
        ) { [weak self] _ in
            self?.deleteBook(book)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        presenter?.present(alertController)
    }
}

// Extension for handling updates from the BookCRUDViewModel
extension BooksViewModel: BookCRUDViewModelListener {
    
    // Handle addition of a new book
    func add(book: Book) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.delayDuration) { [weak self] in
            guard let self = self else { return }
            self.books.append(book)
            let indexPath = IndexPath(row: self.books.count - 1, section: 0)
            self.presenter?.insertRows(at: [indexPath])
            self.scroll(to: indexPath, at: .bottom)
        }
    }
    
    // Handle updating an existing book
    func update(book: Book) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.delayDuration) { [weak self] in
            guard let self = self,
                  let index = self.books.firstIndex(where: { $0.id == book.id }) else { return }
            self.books[index] = book
            let indexPath = IndexPath(row: index, section: 0)
            self.presenter?.reloadRows(at: [indexPath])
            self.scroll(to: indexPath, at: .middle)
        }
    }
}
