//
//  PhotoCollectionViewCell.swift
//  Location
//
//  Created by 최정안 on 2/4/25.
//

import UIKit
import SnapKit

final class PhotoCollectionViewCell: UICollectionViewCell {
    
    static let id = "PhotoCollectionViewCell"
    
    private let photoImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    func configureData(img: UIImage) {
        photoImageView.image = img
    }
    private func configureView() {
        contentView.addSubview(photoImageView)
        
        photoImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
