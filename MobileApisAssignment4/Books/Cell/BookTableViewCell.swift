//
//  BookTableViewCell.swift
//  MobileApisAssignment4
//
//  Created by Abhijit Singh on 15/11/23.
//

import UIKit

final class BookTableViewCell: UITableViewCell,
                               ViewLoadable {
    
    static let name = Constants.bookCell
    static let identifier = Constants.bookCell
    
    @IBOutlet private weak var ratingContainerView: UIView!
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var creationDateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
}

// MARK: - Exposed Helpers
extension BookTableViewCell {
    
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
    
    func setup() {
        ratingContainerView.layer.cornerRadius = 12
        ratingContainerView.layer.borderWidth = 3
    }
    
}

// MARK: - BookCellViewModel.RatingState Helpers
private extension BookCellViewModel.RatingState {
    
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
