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
    
    private lazy var doneButton: UIBarButtonItem = {
        return UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneButtonTapped)
        )
    }()
    
    private lazy var doneSpinnerView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = true
        return view
    }()
    
    var viewModel: BookCRUDViewModelable?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
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
    
    func startLoadingDoneButton() {
        view.isUserInteractionEnabled = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneSpinnerView)
        doneSpinnerView.startAnimating()
    }
    
    func stopLoadingDoneButton() {
        view.isUserInteractionEnabled = true
        doneSpinnerView.stopAnimating()
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func setNavigationTitle(_ title: String) {
        navigationItem.title = title
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
    
    func pop() {
        navigationController?.popViewController(animated: true)
    }
    
}
