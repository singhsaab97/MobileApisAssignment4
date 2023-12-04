//
//  BookTableViewCell.swift
//  MobileApisAssignment4
//
//  Created by Kosisochukwu Abone on 15/11/23.
//

import UIKit

// BookTableViewCell class represents a custom UITableViewCell for displaying book information.
final class BookTableViewCell: UITableViewCell, ViewLoadable {
    
    // MARK: - Constants
    
    // Constants for the cell's name and identifier
    static let name = Constants.bookCell
    static let identifier = Constants.bookCell
    
    // MARK: - Outlets
    
    // Outlets for UI elements in the cell
    @IBOutlet private weak var ratingContainerView: UIView!
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var creationDateLabel: UILabel!
    
    // MARK: - Initialization
    
    // Called when the cell is awakened from a nib or storyboard
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
}

// MARK: - Exposed Helpers
extension BookTableViewCell {
    
    // Configure the cell with data from the view model
    func configure(with viewModel: BookCellViewModelable) {
        ratingContainerView.backgroundColor = viewModel.state.color.withAlphaComponent(0.6)
        ratingContainerView.layer.borderColor = viewModel.state.color.cgColor
        ratingLabel.text = viewModel.bookRating
        nameLabel.text = viewModel.book.name
        authorLabel.text = viewModel.book.author
        let creationDate = viewModel.creationDate
        creationDateLabel.text = creationDate
        creationDateLabel.isHidden = creationDate.isEmpty
    }
    
}

// MARK: - Private Helpers
private extension BookTableViewCell {
    
    // Set up the cell's appearance
    func setup() {
        ratingContainerView.layer.cornerRadius = 12
        ratingContainerView.layer.borderWidth = 3
    }
    
}

// MARK: - BookCellViewModel.RatingState Helpers
private extension BookCellViewModel.RatingState {
    
    // Determine the color based on the rating state
    var color: UIColor {
        switch self {
        case .good:
            return .systemGreen
        case .okay:
            return .systemYellow
        case .meh:
            return .systemOrange
        case .bad:
            return .systemRed
        case .unknown:
            return .clear
        }
    }
    
}
