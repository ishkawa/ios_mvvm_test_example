//
//  EmptyCell.swift
//  Demo
//
//  Created by Yosuke Ishikawa on 2019/01/14.
//  Copyright © 2019 Yosuke Ishikawa. All rights reserved.
//

import UIKit
import DataSourceKit

final class EmptyCell: UICollectionViewCell {
    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        layoutAttributes.size = superview?.frame.size ?? UIScreen.main.bounds.size
        return layoutAttributes
    }
}

extension EmptyCell: BindableCell {
    static func makeBinder(value isLoading: Bool) -> CellBinder {
        return CellBinder(
            cellType: EmptyCell.self,
            registrationMethod: .none,
            reuseIdentifier: "EmptyCell",
            configureCell: { cell in
                cell.messageLabel.isHidden = isLoading
                
                if isLoading {
                    cell.activityIndicatorView.startAnimating()
                } else {
                    cell.activityIndicatorView.stopAnimating()
                }
            })
    }
}
