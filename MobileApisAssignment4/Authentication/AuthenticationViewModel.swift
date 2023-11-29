//
//  AuthenticationViewModel.swift
//  MobileApisAssignment4
//
//  Created by Abhijit Singh on 15/11/23.
//

import UIKit

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

final class AuthenticationViewModel: AuthenticationViewModelable,
                                     Toastable {
    
    enum Flow {
        case signUp
        case signIn
    }
    
    enum Field: Int, CaseIterable {
        case firstName
        case lastName
        case email
        case password
        case confirmPassword
    }

    let flow: Flow
    weak var presenter: AuthenticationPresenter?
    
    /// Map to keep a track of password visibilty for protected fields
    private var protectedFieldsHiddenDict: [Field: Bool]
    
    init(flow: Flow) {
        self.flow = flow
        self.protectedFieldsHiddenDict = [:]
    }
    
}

// MARK: - Exposed Helpers
extension AuthenticationViewModel {
    
    func screenDidLoad() {
        setupProtectedFieldsHiddenDict()
    }
    
    func screenDidAppear() {
        presenter?.activateTextField(flow.activeTextField)
    }
    
    func keyboardWillShow(with frame: CGRect) {
        if flow.allowsHiddenHeading {
            presenter?.updateHeadingStackView(isHidden: true)
        }
        presenter?.showKeyboard(with: frame.height, duration: Constants.animationDuration)
    }
    
    func keyboardWillHide() {
        if flow.allowsHiddenHeading {
            presenter?.updateHeadingStackView(isHidden: false)
        }
        presenter?.hideKeyboard(with: Constants.animationDuration)
    }
    
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
    
    func primaryButtonTapped() {
        for field in flow.fields {
            guard validateField(field) else { return }
        }
        // This code won't be executed if a validation error is found
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
    
    func messageButtonTapped() {
        showNextFlowScreen()
    }
    
}

// MARK: - Private Helpers
private extension AuthenticationViewModel {
    
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
        // No error found
        return true
    }
    
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
    
    func signIn(with emailId: String, password: String) {
        presenter?.startLoading()
        DataHandler.shared.signIn(with: emailId, password: password) { result in
            DispatchQueue.main.async { [weak self] in
                self?.handleAuthenticationResult(result)
            }
        }
    }
    
    func showNextFlowScreen() {
        guard let controllersCount = presenter?.viewControllersCount,
              controllersCount > 1 else {
            // New controller not present in the stack
            let viewModel = AuthenticationViewModel(flow: flow.nextFlow)
            let viewController = AuthenticationViewController.loadFromStoryboard()
            viewController.viewModel = viewModel
            viewModel.presenter = viewController
            presenter?.push(viewController)
            return
        }
        // Old controller already present in the stack
        presenter?.pop()
    }
    
    func handleAuthenticationResult(_ result: Result<Data, Error>) {
        presenter?.stopLoading()
        switch result {
        case let .success(data):
            guard let error = data.error else {
                switch flow {
                case .signUp:
                    showNextFlowScreen()
                case .signIn:
                    if let authToken = data.toJson?["token"] as? String {
                        showBooksScreen(with: authToken)
                    }
                }
                return
            }
            showToast(with: error)
        case let .failure(error):
            showToast(with: error.localizedDescription)
        }
    }
    
    func showBooksScreen(with authToken: String) {
        // Clear text fields before showing the main screen
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.delayDuration) { [weak self] in
            self?.presenter?.clearDetailFields()
        }
        let viewController = BooksViewController.loadFromStoryboard()
        let viewModel = BooksViewModel(authToken: authToken, listener: self)
        viewController.viewModel = viewModel
        viewModel.presenter = viewController
        // Initiate a new navigation controller
        let navigationController = viewController.embeddedInNavigationController
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.isTranslucent = true
        presenter?.present(navigationController)
    }
    
}

// MARK: - BooksViewModelListener Methods
extension AuthenticationViewModel: BooksViewModelListener {

    func userLoggingOut() {
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
        switch self {
        case .signUp:
            return Constants.registrationFailedMessage
        case .signIn:
            return Constants.authenticationFailedMessage
        }
    }
    
    var allowsHiddenHeading: Bool {
        switch self {
        case .signUp:
            return true
        case .signIn:
            return false
        }
    }
    
    var activeTextField: AuthenticationViewModel.Field {
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
        switch self {
        case .firstName, .lastName, .email:
            return false
        case .password, .confirmPassword:
            return true
        }
    }
    
    var errorMessage: String {
        return "\(placeholder) \(Constants.fieldErrorMessageSubtext)"
    }
    
}

// MARK: - AuthenticationViewModel.Flow Helpers
private extension AuthenticationViewModel.Flow {
    
    var nextFlow: AuthenticationViewModel.Flow {
        switch self {
        case .signUp:
            return .signIn
        case .signIn:
            return .signUp
        }
    }
    
}
