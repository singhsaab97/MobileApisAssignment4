//
//  BookCRUDViewController.swift
//  MobileApisAssignment4
//
//  Created by Abhijit Singh on 27/11/23.
//

import UIKit

// View controller for handling book creation, updating, and deletion
final class BookCRUDViewController: UIViewController, ViewLoadable {
    
    // MARK: - Constants
    
    static let name = Constants.storyboardName
    static let identifier = Constants.bookCRUDViewController
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var spinnerView: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    
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
    
    // MARK: - View Model
    
    var viewModel: BookCRUDViewModelable?
    
    // MARK: - Lifecycle Methods
    
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
    
    // Setup initial configurations
    func setup() {
        BookFieldTableViewCell.register(for: tableView)
        addDoneButton()
        addKeyboardObservers()
        viewModel?.screenDidLoad()
    }
    
    // Add the "Done" button to the navigation bar
    func addDoneButton() {
        navigationItem.rightBarButtonItem = doneButton
    }
    
    // Add keyboard observers to manage keyboard events
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
    
    // Adjust UI when the keyboard is about to show
    func keyboardWillShow(_ notification: Notification) {
        guard let frame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        viewModel?.keyboardWillShow(with: frame)
    }
    
    // Adjust UI when the keyboard is about to hide
    func keyboardWillHide() {
        viewModel?.keyboardWillHide()
    }
    
    // Handle "Done" button tap
    @objc
    func doneButtonTapped() {
        viewModel?.doneButtonTapped()
    }
    
}

// MARK: - UITableViewDataSource Methods
extension BookCRUDViewController: UITableViewDataSource {
    
    // Number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfFields ?? 0
    }
    
    // Configure and return a table view cell for a specific row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel?.getCellViewModel(at: indexPath) else { return UITableViewCell() }
        let fieldCell = BookFieldTableViewCell.dequeReusableCell(from: tableView, at: indexPath)
        fieldCell.configure(with: viewModel)
        return fieldCell
    }
    
}

// MARK: - BookCRUDViewModelPresenter Methods

extension BookCRUDViewController: BookCRUDViewModelPresenter {
    
    // Start loading state
    func startLoading() {
        spinnerView.isHidden = false
        spinnerView.startAnimating()
    }
    
    // Stop loading state
    func stopLoading() {
        spinnerView.stopAnimating()
        spinnerView.isHidden = true
    }
    
    // Start loading state for the "Done" button
    func startLoadingDoneButton() {
        view.isUserInteractionEnabled = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneSpinnerView)
        doneSpinnerView.startAnimating()
    }
    
    // Stop loading state for the "Done" button
    func stopLoadingDoneButton() {
        view.isUserInteractionEnabled = true
        doneSpinnerView.stopAnimating()
        navigationItem.rightBarButtonItem = doneButton
    }
    
    // Set navigation title
    func setNavigationTitle(_ title: String) {
        navigationItem.title = title
    }
    
    // Reload specified sections in the table view
    func reloadSections(_ indexSet: IndexSet) {
        tableView.reloadSections(indexSet, with: .fade)
    }
    
    // Show the keyboard with specified height and duration
    func showKeyboard(with height: CGFloat, duration: TimeInterval) {
        tableViewBottomConstraint.constant = height
        UIView.animate(withDuration: duration) { [weak self] in
            self?.view?.layoutIfNeeded()
        }
    }
    
    // Hide the keyboard with specified duration
    func hideKeyboard(with duration: TimeInterval) {
        tableViewBottomConstraint.constant = .zero
        UIView.animate(withDuration: duration) { [weak self] in
            self?.view?.layoutIfNeeded()
        }
    }
    
    // Pop the view controller from the navigation stack
    func pop() {
        navigationController?.popViewController(animated: true)
    }
    
}
