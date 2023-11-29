//
//  BookCRUDViewModel.swift
//  MobileApisAssignment4
//
//  Created by Abhijit Singh on 27/11/23.
//

import Foundation

protocol BookCRUDViewModelPresenter: AnyObject {
    func startLoading()
    func stopLoading()
    func setNavigationTitle(_ title: String)
    func updateDoneButton(isEnabled: Bool)
    func reloadSections(_ indexSet: IndexSet)
    func showKeyboard(with height: CGFloat, duration: TimeInterval)
    func hideKeyboard(with duration: TimeInterval)
    func dismiss()
}

protocol BookCRUDViewModelable {
    var numberOfFields: Int { get }
    var presenter: BookCRUDViewModelPresenter? { get set }
    func screenDidLoad()
    func doneButtonTapped()
    func getCellViewModel(at indexPath: IndexPath) -> BookFieldCellViewModel?
    func keyboardWillShow(with frame: CGRect)
    func keyboardWillHide()
}

final class BookCRUDViewModel: BookCRUDViewModelable,
                               Toastable {
    
    enum Field: CaseIterable {
        case name
        case rating
        case author
        case genre
    }
    
    private let bookId: String?
    private let authToken: String
    private let fields: [Field]
    private var book: Book?
    
    weak var presenter: BookCRUDViewModelPresenter?
    
    init(bookId: String?, authToken: String) {
        self.bookId = bookId
        self.authToken = authToken
        self.fields = Field.allCases
    }
    
}

// MARK: - Exposed Helpers
extension BookCRUDViewModel {
    
    var numberOfFields: Int {
        return fields.count
    }
    
    func screenDidLoad() {
        fetchBook()
    }
    
    func doneButtonTapped() {
        // TODO
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> BookFieldCellViewModel? {
        guard let field = fields[safe: indexPath.row] else { return nil }
        var detail = String()
        guard let book = book else {
            return BookFieldCellViewModel(field: field, detail: detail)
        }
        switch field {
        case .name:
            detail = book.name
        case .rating:
            detail = String(book.rating)
        case .author:
            detail = book.author
        case .genre:
            detail = book.genre
        }
        return BookFieldCellViewModel(field: field, detail: detail)
    }
    
    func keyboardWillShow(with frame: CGRect) {
        presenter?.showKeyboard(with: frame.height, duration: Constants.animationDuration)
    }
    
    func keyboardWillHide() {
        presenter?.hideKeyboard(with: Constants.animationDuration)
    }
    
}

// MARK: - Private Helpera
private extension BookCRUDViewModel {
    
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
                    self?.presenter?.setNavigationTitle(Constants.bookDetails)
                    self?.presenter?.reloadSections(IndexSet(integer: 0))
                case let .failure(error):
                    self?.showToast(with: error.localizedDescription)
                }
            }
        }
    }
    
}
