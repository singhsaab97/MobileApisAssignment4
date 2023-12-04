//
//  AuthenticationViewController.swift
//  MobileApisAssignment4
//
//  Created by Abhijit Singh on 15/11/23.
//

import UIKit

// AuthenticationViewController is responsible for displaying and handling user authentication-related UI.
final class AuthenticationViewController: UIViewController,
                                          ViewLoadable {
    
    // Constants for the storyboard and view controller identifier.
    static let name = Constants.storyboardName
    static let identifier = Constants.authenticationViewController
    
    // Outlets for UI elements in the authentication view.
    @IBOutlet private weak var headingStackView: UIStackView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var firstNameTextField: UITextField!
    @IBOutlet private weak var lastNameTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    @IBOutlet private weak var primaryButton: UIButton!
    @IBOutlet private weak var spinnerView: UIActivityIndicatorView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var messageButton: UIButton!
    @IBOutlet private weak var messageStackViewBottomConstraint: NSLayoutConstraint!
    
    // ViewModel responsible for handling the business logic.
    var viewModel: AuthenticationViewModelable?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.screenDidAppear()
    }
    
}

// MARK: - Private Helpers
private extension AuthenticationViewController {
    
    // Sets up the initial UI and invokes ViewModel methods.
    func setup() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupTitleLabel()
        setupSubtitleLabel()
        setupDetailTextFields()
        setupPrimaryButton()
        setupSpinnerView()
        setupMessageLabel()
        setupMessageButton()
        addKeyboardObservers()
        viewModel?.screenDidLoad()
    }
    
    // Sets up the title label with text from ViewModel.
    func setupTitleLabel() {
        titleLabel.text = viewModel?.flow.titleLabelText
    }
    
    // Sets up the subtitle label with text from ViewModel.
    func setupSubtitleLabel() {
        subtitleLabel.text = viewModel?.flow.subtitleLabelText
    }
    
    // Sets up detail text fields based on the ViewModel flow.
    func setupDetailTextFields() {
        viewModel?.flow.fields.forEach { field in
            // Configures text field properties based on ViewModel data.
            let textField = getTextField(for: field)
            textField.tag = field.rawValue
            // Configures placeholder attributes.
            textField.attributedPlaceholder = NSAttributedString(
                string: field.placeholder,
                attributes: [
                    .foregroundColor: UIColor.secondaryLabel,
                    .font: Constants.placeholderFont
                ]
            )
            textField.layer.cornerRadius = 12
            textField.keyboardType = field.keyboardType
            textField.isSecureTextEntry = field.isPasswordProtected
            // Configures left and right views for secure text entry fields.
            configureSecureTextFieldViews(field, textField)
        }
        // Hides specified fields based on ViewModel data.
        viewModel?.flow.hiddenFields.forEach { field in
            let textField = getTextField(for: field)
            textField.isHidden = true
        }
    }
    
    // Sets up the primary button with text from ViewModel.
    func setupPrimaryButton() {
        primaryButton.setTitle(viewModel?.flow.primaryButtonTitle, for: .normal)
        primaryButton.layer.cornerRadius = 12
    }
    
    // Sets up the spinner view for loading state.
    func setupSpinnerView() {
        spinnerView.isHidden = true
    }
    
    // Sets up the message label with text from ViewModel.
    func setupMessageLabel() {
        messageLabel.text = viewModel?.flow.messageLabelText
    }
    
    // Sets up the message button with text from ViewModel.
    func setupMessageButton() {
        messageButton.setTitle(viewModel?.flow.messageButtonTitle, for: .normal)
    }
    
    // Adds keyboard observers to manage UI adjustments during keyboard events.
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
    
    // Returns a text field for the specified `field` type
    func getTextField(for field: AuthenticationViewModel.Field) -> UITextField {
        switch field {
        case .firstName:
            return firstNameTextField
        case .lastName:
            return lastNameTextField
        case .email:
            return emailTextField
        case .password:
            return passwordTextField
        case .confirmPassword:
            return confirmPasswordTextField
        }
    }
    
    // Handles keyboard show event and notifies the ViewModel.
    func keyboardWillShow(_ notification: Notification) {
        guard let frame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        viewModel?.keyboardWillShow(with: frame)
    }
    
    // Handles keyboard hide event and notifies the ViewModel.
    func keyboardWillHide() {
        viewModel?.keyboardWillHide()
    }
    
    // Handles eye button tap event for secure text entry fields.
    @objc
    func eyeButtonTapped(_ sender: UIButton) {
        viewModel?.eyeButtonTapped(with: sender.tag)
    }
    
    // Handles primary button tap event and notifies the ViewModel.
    @IBAction func primaryButtonTapped() {
        viewModel?.primaryButtonTapped()
    }
    
    // Handles message button tap event and notifies the ViewModel.
    @IBAction func messageButtonTapped() {
        viewModel?.messageButtonTapped()
    }
    
}

// MARK: - AuthenticationPresenter Methods
extension AuthenticationViewController: AuthenticationPresenter {
    
    // Properties to get user input from text fields.
    var userFirstName: String? {
        return firstNameTextField.text
    }
    
    var userLastName: String? {
        return lastNameTextField.text
    }
    
    var userEmail: String? {
        return emailTextField.text
    }
    
    var userPassword: String? {
        return passwordTextField.text
    }
    
    var userConfirmedPassword: String? {
        return confirmPasswordTextField.text
    }
    
    // Returns the count of view controllers in the navigation stack.
    var viewControllersCount: Int {
        return navigationController?.viewControllers.count ?? 0
    }
    
    // Methods to handle loading state and UI updates.
    func startLoading() {
        primaryButton.setTitle(nil, for: .normal)
        spinnerView.isHidden = false
        spinnerView.startAnimating()
    }
    
    func stopLoading() {
        spinnerView.stopAnimating()
        spinnerView.isHidden = true
        primaryButton.setTitle(viewModel?.flow.primaryButtonTitle, for: .normal)
    }
    
    // Methods to update UI elements based on ViewModel data.
    func updateHeadingStackView(isHidden: Bool) {
        headingStackView.isHidden = isHidden
    }
    
    func showKeyboard(with height: CGFloat, duration: TimeInterval) {
        let safeAreaBottonInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        let additionalHeight = CGFloat(safeAreaBottonInset.isZero ? 20 : 0)
        messageStackViewBottomConstraint.constant = height + additionalHeight
        UIView.animate(withDuration: duration) { [weak self] in
            self?.view?.layoutIfNeeded()
        }
    }
    
    func hideKeyboard(with duration: TimeInterval) {
        messageStackViewBottomConstraint.constant = 20
        UIView.animate(withDuration: duration) { [weak self] in
            self?.view?.layoutIfNeeded()
        }
    }
    
    func updatePasswordField(_ field: AuthenticationViewModel.Field, isTextHidden: Bool) {
        let textField = getTextField(for: field)
        textField.isSecureTextEntry = isTextHidden
    }
    
    func updateEyeButtonImage(for field: AuthenticationViewModel.Field, with image: UIImage?) {
        let textField = getTextField(for: field)
        guard let button = textField.rightView?.subviews
            .first(where: { $0 is UIButton }) as? UIButton else { return }
        button.setImage(image, for: .normal)
    }
    
    func clearDetailFields() {
        viewModel?.flow.fields.forEach { field in
            let textField = getTextField(for: field)
            textField.text = nil
        }
    }
    
    func activateTextField(_ field: AuthenticationViewModel.Field) {
        let textField = getTextField(for: field)
        textField.becomeFirstResponder()
    }
    
    // Navigation methods to handle view controller transitions.
    func push(_ viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func pop() {
        navigationController?.popViewController(animated: true)
    }
    
    func present(_ viewController: UIViewController) {
        navigationController?.present(viewController, animated: true)
    }
    
}

// MARK: - AuthenticationViewModel.Field Helpers
private extension AuthenticationViewModel.Field {
    
    // Returns the keyboard type based on the field type.
    var keyboardType: UIKeyboardType {
        switch self {
        case .firstName, .lastName:
            return .alphabet
        case .email:
            return .emailAddress
        case .password, .confirmPassword:
            return .default
        }
    }
    
}
