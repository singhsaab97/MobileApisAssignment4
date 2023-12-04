//
//  AuthenticationViewModel.swift
//  MobileApisAssignment4
//
//  Created by Abhijit Singh on 15/11/23.
//

import UIKit

// Protocol defining the interface for presenting authentication-related UI.
protocol AuthenticationPresenter: AnyObject {
    var userFirstName: String? { get }
    var userLastName: String? { get }
    var userEmail: String? { get }
    var userPassword: String? { get }
    var userConfirmedPassword: String? { get }
    var viewControllersCount: Int { get }
    func startLoading()
    func stopLoading()
    func updateHeadingStackView(isHidden: Bool)
    func showKeyboard(with height: CGFloat, duration: TimeInterval)
    func hideKeyboard(with duration: TimeInterval)
    func updatePasswordField(_ field: AuthenticationViewModel.Field, isTextHidden: Bool)
    func updateEyeButtonImage(for field: AuthenticationViewModel.Field, with image: UIImage?)
    func clearDetailFields()
    func activateTextField(_ field: AuthenticationViewModel.Field)
    func push(_ viewController: UIViewController)
    func pop()
    func present(_ viewController: UIViewController)
}

// Protocol defining the interface for the AuthenticationViewModel.
protocol AuthenticationViewModelable {
    var flow: AuthenticationViewModel.Flow { get }
    var presenter: AuthenticationPresenter? { get set }
    func screenDidLoad()
    func screenDidAppear()
    func keyboardWillShow(with frame: CGRect)
    func keyboardWillHide()
    func eyeButtonTapped(with tag: Int)
    func primaryButtonTapped()
    func messageButtonTapped()
}

// ViewModel for handling authentication logic.
final class AuthenticationViewModel: AuthenticationViewModelable, Toastable {
    
    // Enum defining different authentication flows (sign-up, sign-in).
    enum Flow {
        case signUp
        case signIn
    }
    
    // Enum defining different fields in the authentication process.
    enum Field: Int, CaseIterable {
        case firstName
        case lastName
        case email
        case password
        case confirmPassword
    }
    
    // Flow type (sign-up or sign-in) for the current instance of ViewModel.
    let flow: Flow
    weak var presenter: AuthenticationPresenter?
    
    // Dictionary to keep track of password visibility for protected fields.
    private var protectedFieldsHiddenDict: [Field: Bool]
    
    // Initializer with the specified authentication flow.
    init(flow: Flow) {
        self.flow = flow
        self.protectedFieldsHiddenDict = [:]
    }
    
}

// MARK: - Exposed Helpers
extension AuthenticationViewModel {
    
    // Invoked when the screen loads to set up initial configurations.
    func screenDidLoad() {
        setupProtectedFieldsHiddenDict()
    }
    
    // Invoked when the screen appears to perform actions after loading.
    func screenDidAppear() {
        presenter?.activateTextField(flow.activeTextField)
    }
    
    // Handles the keyboard show event and notifies the presenter.
    func keyboardWillShow(with frame: CGRect) {
        if flow.allowsHiddenHeading {
            presenter?.updateHeadingStackView(isHidden: true)
        }
        presenter?.showKeyboard(with: frame.height, duration: Constants.animationDuration)
    }
    
    // Handles the keyboard hide event and notifies the presenter.
    func keyboardWillHide() {
        if flow.allowsHiddenHeading {
            presenter?.updateHeadingStackView(isHidden: false)
        }
        presenter?.hideKeyboard(with: Constants.animationDuration)
    }
    
    // Handles the eye button tap event for secure text entry fields.
    func eyeButtonTapped(with tag: Int) {
        guard let field = Field(rawValue: tag),
              let isHidden = protectedFieldsHiddenDict[field] else { return }
        protectedFieldsHiddenDict[field] = !isHidden
        presenter?.updatePasswordField(field, isTextHidden: !isHidden)
        let eyeButtonImage = !isHidden
        ? UIImage(systemName: "eye.fill")
        : UIImage(systemName: "eye.slash.fill")
        presenter?.updateEyeButtonImage(for: field, with: eyeButtonImage)
    }
    
    // Handles the primary button tap event, validates fields, and initiates authentication.
    func primaryButtonTapped() {
        for field in flow.fields {
            guard validateField(field) else { return }
        }
        // Validation successful, proceed with authentication.
        guard let emailId = presenter?.userEmail,
              let password = presenter?.userPassword else { return }
        switch flow {
        case .signUp:
            guard let firstName = presenter?.userFirstName,
                  let lastName = presenter?.userLastName else { return }
            signUp(with: firstName, lastName: lastName, emailId: emailId, password: password)
        case .signIn:
            signIn(with: emailId, password: password)
        }
    }
    
    // Handles the message button tap event and navigates to the next flow screen.
    func messageButtonTapped() {
        showNextFlowScreen()
    }
    
}

// MARK: - Private Helpers
private extension AuthenticationViewModel {
    
    // Sets up the initial dictionary to track password visibility.
    func setupProtectedFieldsHiddenDict() {
        flow.fields.forEach { field in
            if field.isPasswordProtected {
                protectedFieldsHiddenDict[field] = true
                presenter?.updateEyeButtonImage(
                    for: field,
                    with: UIImage(systemName: "eye.fill")
                )
            }
        }
    }
    
    // Validates the specified field and shows an error message if validation fails.
    func validateField(_ field: Field) -> Bool {
        switch field {
        case .firstName:
            guard let name = presenter?.userFirstName,
                  !name.isEmpty else {
                showToast(with: field.errorMessage)
                return false
            }
        case .lastName:
            guard let name = presenter?.userLastName,
                  !name.isEmpty else {
                showToast(with: field.errorMessage)
                return false
            }
        case .email:
            guard let emailId = presenter?.userEmail,
                  !emailId.isEmpty else {
                showToast(with: field.errorMessage)
                return false
            }
            guard isValidEmail(emailId) else {
                showToast(with: flow.errorMessage)
                return false
            }
        case .password:
            guard let password = presenter?.userPassword,
                  !password.isEmpty else {
                showToast(with: field.errorMessage)
                return false
            }
        case .confirmPassword:
            guard let password = presenter?.userPassword,
                  let confirmedPassword = presenter?.userConfirmedPassword,
                  !confirmedPassword.isEmpty else { return false }
            guard password == confirmedPassword else {
                showToast(with: flow.errorMessage)
                return false
            }
        }
        // No error found, validation successful.
        return true
    }
    
    // Checks if the specified email is in a valid format using a regular expression.
    func isValidEmail(_ email: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: Constants.emailRegex, options: .caseInsensitive)
            let matches = regex.matches(
                in: email,
                options: [],
                range: NSRange(location: 0, length: email.utf16.count)
            )
            return matches.count > 0
        } catch {
            return false
        }
    }
    
    // Initiates sign-up process with the provided user details.
    func signUp(with firstName: String, lastName: String, emailId: String, password: String) {
        presenter?.startLoading()
        DataHandler.shared.signUp(
            with: firstName,
            lastName: lastName,
            emailId: emailId,
            password: password
        ) { result in
            DispatchQueue.main.async { [weak self] in
                self?.handleAuthenticationResult(result)
            }
        }
    }
    
    // Initiates sign-in process with the provided user details.
    func signIn(with emailId: String, password: String) {
        presenter?.startLoading()
        DataHandler.shared.signIn(with: emailId, password: password) { result in
            DispatchQueue.main.async { [weak self] in
                self?.handleAuthenticationResult(result)
            }
        }
    }
    
    // Navigates to the next flow screen based on authentication result.
    func showNextFlowScreen() {
        guard let controllersCount = presenter?.viewControllersCount,
              controllersCount > 1 else {
            // New controller not present in the stack, create and push it.
            let viewModel = AuthenticationViewModel(flow: flow.nextFlow)
            let viewController = AuthenticationViewController.loadFromStoryboard()
            viewController.viewModel = viewModel
            viewModel.presenter = viewController
            presenter?.push(viewController)
            return
        }
        // Old controller already present in the stack, pop to previous screen.
        presenter?.pop()
    }
    
    // Handles the result of the authentication process and takes appropriate actions.
    func handleAuthenticationResult(_ result: Result<Data, Error>) {
        presenter?.stopLoading()
        switch result {
        case let .success(data):
            guard let error = data.error else {
                // Authentication successful, proceed based on the flow type.
                switch flow {
                case .signUp:
                    showNextFlowScreen()
                case .signIn:
                    if let authToken = data.toJson?["token"] as? String {
                        showBooksScreen(with: authToken)
                        UserDefaults.appSuite.set(authToken, forKey: UserDefaults.authTokenKey)
                    }
                }
                return
            }
            showToast(with: error)
        case let .failure(error):
            showToast(with: error.localizedDescription)
        }
    }
    
    // Shows the Books screen with the provided authentication token.
    func showBooksScreen(with authToken: String) {
        // Clear text fields before showing the main screen.
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.delayDuration) { [weak self] in
            self?.presenter?.clearDetailFields()
        }
        let viewController = BooksViewController.loadFromStoryboard()
        let viewModel = BooksViewModel(authToken: authToken, listener: self)
        viewController.viewModel = viewModel
        viewModel.presenter = viewController
        // Initiate a new navigation controller for presentation.
        let navigationController = viewController.embeddedInNavigationController
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.isTranslucent = true
        presenter?.present(navigationController)
    }
    
}

// MARK: - BooksViewModelListener Methods
extension AuthenticationViewModel: BooksViewModelListener {
    
    // Handles user logout by removing the authentication token and navigating to the next flow screen.
    func userLoggingOut() {
        UserDefaults.appSuite.removeObject(forKey: UserDefaults.authTokenKey)
        switch flow {
        case .signUp:
            showNextFlowScreen()
        case .signIn:
            return
        }
    }
    
}

// MARK: - AuthenticationViewModel.Flow Helpers
extension AuthenticationViewModel.Flow {
    
    // Computed properties providing text for UI elements based on the flow type.
    var titleLabelText: String {
        switch self {
        case .signUp:
            return Constants.signUpTitle
        case .signIn:
            return Constants.signInTitle
        }
    }
    
    var subtitleLabelText: String {
        switch self {
        case .signUp:
            return Constants.signUpSubtitle
        case .signIn:
            return Constants.signInSubtitle
        }
    }
    
    var fields: [AuthenticationViewModel.Field] {
        switch self {
        case .signUp:
            return [.firstName, .lastName, .email, .password, .confirmPassword]
        case .signIn:
            return [.email, .password]
        }
    }
    
    var hiddenFields: [AuthenticationViewModel.Field] {
        return AuthenticationViewModel.Field.allCases.filter { !fields.contains($0) }
    }
    
    var primaryButtonTitle: String {
        switch self {
        case .signUp:
            return Constants.signUp
        case .signIn:
            return Constants.signIn
        }
    }
    
    var messageLabelText: String {
        switch self {
        case .signUp:
            return Constants.signUpMessage
        case .signIn:
            return Constants.signInMessage
        }
    }
    
    var messageButtonTitle: String {
        // Computed property for the message button title based on the flow type.
        let title: String
        switch self {
        case .signUp:
            title = Constants.signIn
        case .signIn:
            title = Constants.signUp
        }
        return " \(title)"
    }
    
    var errorMessage: String {
        // Computed property for the error message based on the flow type.
        switch self {
        case .signUp:
            return Constants.registrationFailedMessage
        case .signIn:
            return Constants.authenticationFailedMessage
        }
    }
    
    var allowsHiddenHeading: Bool {
        // Computed property indicating whether the heading is allowed to be hidden based on the flow type.
        switch self {
        case .signUp:
            return true
        case .signIn:
            return false
        }
    }
    
    var activeTextField: AuthenticationViewModel.Field {
        // Computed property indicating the active text field based on the flow type.
        switch self {
        case .signUp:
            return .firstName
        case .signIn:
            return .email
        }
    }
    
}

// MARK: - AuthenticationViewModel.Field Helpers
extension AuthenticationViewModel.Field {
    
    // Computed properties providing placeholder, password protection status, and error message for the field.
    var placeholder: String {
        switch self {
        case .firstName:
            return Constants.firstNameFieldPlaceholder
        case .lastName:
            return Constants.lastNameFieldPlaceholder
        case .email:
            return Constants.emailFieldPlaceholder
        case .password:
            return Constants.passwordFieldPlaceholder
        case .confirmPassword:
            return Constants.confirmPasswordFieldPlaceholder
        }
    }
    
    var isPasswordProtected: Bool {
        // Computed property indicating whether the field is password-protected.
        switch self {
        case .firstName, .lastName, .email:
            return false
        case .password, .confirmPassword:
            return true
        }
    }
    
    var errorMessage: String {
        // Computed property providing an error message for the field.
        return "\(placeholder) \(Constants.fieldErrorMessageSubtext)"
    }
    
}

// MARK: - AuthenticationViewModel.Flow Helpers
private extension AuthenticationViewModel.Flow {
    
    // Computed property indicating the next flow based on the current flow.
    var nextFlow: AuthenticationViewModel.Flow {
        switch self {
        case .signUp:
            return .signIn
        case .signIn:
            return .signUp
        }
    }
    
}
