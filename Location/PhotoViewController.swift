//
//  PhotoViewController.swift
//  Location
//
//  Created by 최정안 on 2/4/25.
//

import UIKit
import SnapKit
import PhotosUI

final class PhotoViewController: UIViewController {

    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
    private var imageList = [UIImage]()
    
    var content: ((UIImage) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()

    }
    private func createCollectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let sectionInset: CGFloat = 10
        let cellSpacing: CGFloat = 10
        let ColViewWidth:CGFloat = UIScreen.main.bounds.width
        let cellWidth = ColViewWidth - (sectionInset * 2) - (cellSpacing * 2 )
        layout.itemSize = CGSize(width: cellWidth / 3, height: cellWidth / 3)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return layout
    }
    private func configureView() {
        view.backgroundColor = .white
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.id)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(pickerButtonClicked))
    }
    @objc private func pickerButtonClicked() {
        var configureation = PHPickerConfiguration()
        configureation.filter = .any(of: [.images, .screenshots])
        configureation.selectionLimit = 20
        configureation.mode = .default
        
        let picker = PHPickerViewController(configuration: configureation)
        picker.delegate = self
        present(picker,animated: true)
    }
    
}
extension PhotoViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        let group = DispatchGroup()
        
        for result in results {
            let itemProvider = result.itemProvider
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    group.enter()
                    itemProvider.loadObject(ofClass: UIImage.self) { image, error  in
                        DispatchQueue.main.async {
                            if let img = image as? UIImage {
                                self.imageList.append(img)
                            }
                            group.leave()
                        }
                    }
                }
        }
        group.notify(queue: .main) {
            self.collectionView.reloadData()
            self.dismiss(animated: true)
        }


    }
    
    
}
extension PhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.id, for: indexPath) as? PhotoCollectionViewCell else {return UICollectionViewCell()}
        cell.configureData(img: imageList[indexPath.item])
        cell.backgroundColor = .red
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        content?(imageList[indexPath.item])
        navigationController?.popViewController(animated: true)
    }
    
    
}
