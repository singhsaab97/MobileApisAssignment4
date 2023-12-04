//
//  BookCRUDViewModel.swift
//  MobileApisAssignment4
//
//  Created by Abhijit Singh on 27/11/23.
//

import Foundation

// Protocol for communication from BookCRUDViewModel to the associated listener
protocol BookCRUDViewModelListener: AnyObject {
    func add(book: Book)
    func update(book: Book)
}

// Protocol for presenting actions and managing UI in BookCRUDViewModel
protocol BookCRUDViewModelPresenter: AnyObject {
    func startLoading()
    func stopLoading()
    func startLoadingDoneButton()
    func stopLoadingDoneButton()
    func setNavigationTitle(_ title: String)
    func reloadSections(_ indexSet: IndexSet)
    func showKeyboard(with height: CGFloat, duration: TimeInterval)
    func hideKeyboard(with duration: TimeInterval)
    func pop()
}

// Protocol defining the interface for BookCRUDViewModel
protocol BookCRUDViewModelable {
    var numberOfFields: Int { get }
    var presenter: BookCRUDViewModelPresenter? { get set }
    func screenDidLoad()
    func doneButtonTapped()
    func getCellViewModel(at indexPath: IndexPath) -> BookFieldCellViewModel?
    func keyboardWillShow(with frame: CGRect)
    func keyboardWillHide()
}

// Implementation of BookCRUDViewModel
final class BookCRUDViewModel: BookCRUDViewModelable, Toastable {
    
    // Enum defining different fields in the book details
    enum Field: CaseIterable {
        case name
        case rating
        case author
        case genre
    }
    
    private let bookId: String?
    private let authToken: String
    private let fields: [Field]
    private var book: Book
    private var editableBook: Book
    
    private weak var listener: BookCRUDViewModelListener?
    
    weak var presenter: BookCRUDViewModelPresenter?
    
    // Initialization with necessary parameters
    init(bookId: String?, authToken: String, listener: BookCRUDViewModelListener?) {
        self.bookId = bookId
        self.authToken = authToken
        self.fields = Field.allCases
        self.book = Book.newObject
        self.editableBook = book
        self.listener = listener
    }
    
}

// MARK: - Exposed Helpers
extension BookCRUDViewModel {
    
    // Number of fields in the book details
    var numberOfFields: Int {
        return fields.count
    }
    
    // Load screen and fetch book details if bookId is provided
    func screenDidLoad() {
        fetchBook()
    }
    
    // Handle "Done" button tap
    func doneButtonTapped() {
        guard doesPassValidation else { return }
        guard editableBook.isEqual(to: book) else {
            bookId == nil ? addBook() : updateBook()
            return
        }
        showToast(with: Constants.bookExists)
    }
    
    // Get view model for a specific field at an index path
    func getCellViewModel(at indexPath: IndexPath) -> BookFieldCellViewModel? {
        guard let field = fields[safe: indexPath.row] else { return nil }
        let detail: String
        switch field {
        case .name:
            detail = editableBook.name
        case .rating:
            detail = String(editableBook.rating)
        case .author:
            detail = editableBook.author
        case .genre:
            detail = editableBook.genre
        }
        return BookFieldCellViewModel(field: field, detail: detail, listener: self)
    }
    
    // Handle keyboard show event
    func keyboardWillShow(with frame: CGRect) {
        presenter?.showKeyboard(with: frame.height, duration: Constants.animationDuration)
    }
    
    // Handle keyboard hide event
    func keyboardWillHide() {
        presenter?.hideKeyboard(with: Constants.animationDuration)
    }
    
}

// MARK: - Private Helpers
private extension BookCRUDViewModel {
    
    // Validation check for all fields
    var doesPassValidation: Bool {
        for field in fields {
            switch field {
            case .name:
                guard !editableBook.name.isEmpty else {
                    showToast(with: field.validationMessage)
                    return false
                }
            case .rating:
                guard !String(editableBook.rating).isEmpty else {
                    showToast(with: field.validationMessage)
                    return false
                }
                guard editableBook.rating >= 0 && editableBook.rating <= 5 else {
                    showToast(with: Constants.ratingOutOfBounds)
                    return false
                }
            case .author:
                guard !editableBook.author.isEmpty else {
                    showToast(with: field.validationMessage)
                    return false
                }
            case .genre:
                guard !editableBook.genre.isEmpty else {
                    showToast(with: field.validationMessage)
                    return false
                }
            }
        }
        return true
    }
    
    // Fetch book details from the server
    func fetchBook() {
        guard let bookId = bookId else {
            presenter?.setNavigationTitle(Constants.addBook)
            return
        }
        presenter?.startLoading()
        DataHandler.shared.fetchBook(with: bookId, authToken: authToken) { result in
            DispatchQueue.main.async { [weak self] in
                self?.presenter?.stopLoading()
                switch result {
                case let .success(data):
                    guard let book = try? JSONDecoder().decode(Book.self, from: data) else { return }
                    self?.book = book
                    self?.editableBook = book
                    self?.presenter?.setNavigationTitle(Constants.bookDetails)
                    self?.presenter?.reloadSections(IndexSet(integer: 0))
                case let .failure(error):
                    self?.showToast(with: error.localizedDescription)
                }
            }
        }
    }
    
    // Add a new book to the server
    func addBook() {
        presenter?.startLoadingDoneButton()
        DataHandler.shared.addBook(editableBook, authToken: authToken) { result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                presenter?.stopLoadingDoneButton()
                switch result {
                case let .success(data):
                    guard let newBook = try? JSONDecoder().decode(Book.self, from: data) else { return }
                    editableBook = newBook
                    presenter?.pop()
                    listener?.add(book: editableBook)
                case let .failure(error):
                    showToast(with: error.localizedDescription)
                }
            }
        }
    }
    
    // Update an existing book on the server
    func updateBook() {
        presenter?.startLoadingDoneButton()
        DataHandler.shared.updateBook(editableBook, authToken: authToken) { result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                presenter?.stopLoadingDoneButton()
                switch result {
                case .success:
                    presenter?.pop()
                    listener?.update(book: editableBook)
                case let .failure(error):
                    showToast(with: error.localizedDescription)
                }
            }
        }
    }
    
}

// MARK: - BookFieldCellViewModelListener Methods
extension BookCRUDViewModel: BookFieldCellViewModelListener {
    
    // Update the field value in the editable book
    func fieldUpdated(_ field: Field, with text: String?) {
        guard let text = text else { return }
        switch field {
        case .name:
            editableBook.name = text
        case .rating:
            editableBook.rating = Double(text) ?? .zero
        case .author:
            editableBook.author = text
        case .genre:
            editableBook.genre = text
        }
    }
    
}

// MARK: - BookCRUDViewModel.Field Helpers
private extension BookCRUDViewModel.Field {
    
    // Validation error message for each field
    var validationMessage: String {
        return "\(placeholder) \(Constants.fieldErrorMessageSubtext)"
    }
    
}
