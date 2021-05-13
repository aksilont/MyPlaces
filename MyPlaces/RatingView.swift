//
//  RatingView.swift
//  MyPlaces
//
//  Created by Aksilont on 11.05.2021.
//

import UIKit

@IBDesignable class RatingView: UIView {
    
    // MARK: - Properties
    
    private var stars: [UIImageView] = []
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.frame = frame
        return stack
    }()
    
    var rating = 0 {
        didSet {
            if rating != oldValue { setup() }
        }
    }
    
    @IBInspectable var starSize: CGSize = CGSize(width: 14.0, height: 14.0) {
        didSet {
            setup()
        }
    }
    
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setup()
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Private methods
    
    private func setup() {
        backgroundColor = .clear
        
        stars.forEach { starView in
            starView.removeFromSuperview()
            mainStack.removeArrangedSubview(starView)
        }
        stars.removeAll()
        mainStack.removeFromSuperview()
        
        let filledStar = UIImage(systemName: "star.fill")
        let emptyStar = UIImage(systemName: "star")
        
        (1...starCount).forEach { numberStar in
            let starImageView = UIImageView()
            
            starImageView.tintColor = .black
            starImageView.image = rating < numberStar ? emptyStar : filledStar
            
            starImageView.translatesAutoresizingMaskIntoConstraints = false
            starImageView.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            starImageView.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            
            stars.append(starImageView)
            mainStack.addArrangedSubview(starImageView)
        }
        addSubview(mainStack)
    }

}
