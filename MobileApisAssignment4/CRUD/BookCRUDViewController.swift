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
    @IBOutlet private weak var tableViewBottomConstraint: NSLayoutConstraint!
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
        BookFieldTableViewCell.register(for: tableView)
        addDoneButton()
        addKeyboardObservers()
        viewModel?.screenDidLoad()
    }
    
    func addDoneButton() {
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneButtonTapped)
        )
        doneButton.isEnabled = false
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            self?.keyboardWillShow(notification)
        }
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            self?.keyboardWillHide()
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        guard let frame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        viewModel?.keyboardWillShow(with: frame)
    }
    
    func keyboardWillHide() {
        viewModel?.keyboardWillHide()
    }
    
    @objc
    func doneButtonTapped() {
        viewModel?.doneButtonTapped()
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
        return viewModel?.numberOfFields ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel?.getCellViewModel(at: indexPath) else { return UITableViewCell() }
        let fieldCell = BookFieldTableViewCell.dequeReusableCell(from: tableView, at: indexPath)
        fieldCell.configure(with: viewModel)
        return fieldCell
    }
    
}

// MARK: - BookCRUDViewModelPresenter Methods
extension BookCRUDViewController: BookCRUDViewModelPresenter {
    
    func startLoading() {
        spinnerView.isHidden = false
        spinnerView.startAnimating()
    }
    
    func stopLoading() {
        spinnerView.stopAnimating()
        spinnerView.isHidden = true
    }
    
    func setNavigationTitle(_ title: String) {
        navigationItem.title = title
    }
    
    func updateDoneButton(isEnabled: Bool) {
        // TODO
    }
    
    func reloadSections(_ indexSet: IndexSet) {
        tableView.reloadSections(indexSet, with: .fade)
    }
    
    func showKeyboard(with height: CGFloat, duration: TimeInterval) {
        tableViewBottomConstraint.constant = height
        UIView.animate(withDuration: duration) { [weak self] in
            self?.view?.layoutIfNeeded()
        }
    }
    
    func hideKeyboard(with duration: TimeInterval) {
        tableViewBottomConstraint.constant = .zero
        UIView.animate(withDuration: duration) { [weak self] in
            self?.view?.layoutIfNeeded()
        }
    }
    
    func dismiss() {
        navigationController?.popViewController(animated: true)
    }
    
}
