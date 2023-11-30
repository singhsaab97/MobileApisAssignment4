//
//  Constants.swift
//  MobileApisAssignment4
//
//  Created by Abhijit Singh on 15/11/23.
//

import UIKit

struct Constants {
    
    static let placeholderFont = UIFont(name: "Helvetica Neue", size: 16)!
    static let animationDuration: TimeInterval = 0.3
    static let delayDuration: TimeInterval = 0.5
    static let toastDisplayDuration: TimeInterval = 3
    
    static let storyboardName = "Main"
    static let authenticationViewController = String(describing: AuthenticationViewController.self)
    static let booksViewController = String(describing: BooksViewController.self)
    static let bookCRUDViewController = String(describing: BookCRUDViewController.self)
    static let bookCell = String(describing: BookTableViewCell.self)
    static let bookFieldCell = String(describing: BookFieldTableViewCell.self)
    static let toastView = String(describing: ToastView.self)
    
    static let signUpTitle = "Create account"
    static let signUpSubtitle = "Please fill your details in the form below"
    static let signUpMessage = "Already have an account?"
    static let signUp = "Sign Up"
    static let signInTitle = "Welcome back"
    static let signInSubtitle = "Please log in with your details below"
    static let signInMessage = "Don't have an account?"
    static let signIn = "Sign In"
    static let firstNameFieldPlaceholder = "First name"
    static let lastNameFieldPlaceholder = "Last name"
    static let emailFieldPlaceholder = "Email address"
    static let passwordFieldPlaceholder = "Password"
    static let confirmPasswordFieldPlaceholder = "Confirm password"
    static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    static let registrationFailedMessage = "Registration failed"
    static let authenticationFailedMessage = "Authentication failed"
    static let fieldErrorMessageSubtext = "is required"
    
    static let books = "Books"
    static let goodRating: Double = 4
    static let okayRating: Double = 3
    static let mehRating: Double = 2
    static let badRating: Double = 1
    static let inputCreationDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    static let outputCreationDateFormat = "dd MMMM, yyyy"
    static let delete = "Delete"
    static let deleteAlertMessage = "This action will delete this book permanently."
    static let logoutAlertMessage = "You will have to sign in again once you log out."
    static let logoutAlertTitle = "Logout?"
    static let logoutAlertLogoutTitle = "Logout"
    static let alertCancelTitle = "Cancel"
    
    static let addBook = "Add book"
    static let bookDetails = "Book details"
    static let nameFieldPlaceholder = "Name"
    static let ratingFieldPlaceholder = "Rating (out of 5)"
    static let authorFieldPlaceholder = "Author"
    static let genreFieldPlaceholder = "Genre"
    static let ratingOutOfBounds = "Rating must fall between 0 and 5"
    static let bookExists = "A matching book already exists"

    static let baseUrlPath = "https://book-app-mdev1004-7cd0dc8e1c90.herokuapp.com/"
    static let getMethod = "GET"
    static let postMethod = "POST"
    static let putMethod = "PUT"
    static let deleteMethod = "DELETE"
    static let genericResponseError = "Something went wrong. Please try again in some time"
    
}
