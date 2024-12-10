//
//  HorizontalAlignedCell 2.swift
//  diffable
//
//  Created by Davit K. on 11.12.24.
//

import UIKit

class HorizontalAlignedView: UICollectionReusableView {
    static let reuseIdentifier = "HorizontalAlignedView"
    
    // MARK: - Subviews
    private let circleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20 // Adjust for the circle size
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chevronButton: UIButton = {
        let button = UIButton(type: .system)
        let chevronImage = UIImage(systemName: "chevron.down")
        button.setImage(chevronImage, for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(circleImageView)
        addSubview(titleLabel)
        addSubview(chevronButton)
        setupConstraints()
        chevronButton.addTarget(self, action: #selector(didTapOnChevronButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Circle Image View
            circleImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            circleImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            circleImageView.widthAnchor.constraint(equalToConstant: 40),
            circleImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // Title Label
            titleLabel.leadingAnchor.constraint(equalTo: circleImageView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronButton.leadingAnchor, constant: -8),
            
            // Chevron Button
            chevronButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            chevronButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    var didTapOnChevron: (() -> Void)?
    
    @objc func didTapOnChevronButton() {
        didTapOnChevron?()
    }
    
    // MARK: - Configuration
    func configure(with title: String, image: UIImage?, handler: @escaping () -> Void) {
        titleLabel.text = title
        circleImageView.image = image
        self.didTapOnChevron = handler
    }
}
