//
//  PhotosController.swift
//  InfiniteFlickr
//
//  Created by Julio Estrada on 2/18/18.
//  Copyright © 2018 Julio Estrada. All rights reserved.
//

import UIKit

class PhotosController: UIViewController {

    // MARK: - Properties
    var collectionView: UICollectionView!
    var searchController: UISearchController!
    var store: PhotoStore!
    let photoDataSource = PhotoDataSource()
    let cellId = "photoCell"

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        self.updateDataSource()
        
    }

    // MARK: - Functions
    private func updateDataSource() {
        store.fetchAllPhotos { (photosResult) in
            switch photosResult {
            case let .success(photos):
                self.photoDataSource.photos = photos
            case .failure:
                self.photoDataSource.photos.removeAll()
            }
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }

    // MARK: - Set up views
    private func setupViews() {
        view.backgroundColor = .white
        setupNavBar()
        setupSearchController()
        setupCollectionView()
    }

    private func setupNavBar() {
        navigationItem.title = "InfiniFlickr"
        navigationController?.navigationBar.prefersLargeTitles = true
        let favoritesBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "heart_active"), style: .done, target: self, action: #selector(showFavorites(_:)))
        
        navigationItem.rightBarButtonItem = favoritesBarButtonItem
    }

    @objc func showFavorites(_ sender: UIBarButtonItem) {
        let favController = UINavigationController(rootViewController: FavoritesController())
        present(favController, animated: true, completion: nil)
    }

    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController

        view.addSubview(searchController.searchBar)
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self.photoDataSource
        collectionView.delegate = self

        view.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: cellId)
    }
}

extension PhotosController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        store.searchFlickr(with: searchText) { (photosResult) in
            switch photosResult {
            case let .success(photos):
                self.photoDataSource.photos = photos
            case .failure:
                self.photoDataSource.photos.removeAll()
            }
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
}

extension PhotosController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //        let padding: CGFloat = 50
        //        let collectionViewSize = collectionView.frame.size.width - padding
        //        return CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
        return CGSize(width: view.bounds.width, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        
        if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
            let photo = photoDataSource.photos[selectedIndexPath.row]
            let destinationVC = PhotoDetailController()
            destinationVC.photo = photo
            destinationVC.store = store
            navigationController?.show(destinationVC, sender: cell)
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = photoDataSource.photos[indexPath.row]

        store.fetchImage(for: photo) { (result) in
            guard let photoIndex = self.photoDataSource.photos.index(of: photo),
            case let .success(image) = result else {
                return
            }
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
            if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoCell {
                cell.update(with: image)
            }
        }
    }

    // TODO: - Implement infinite scroll
    
}

