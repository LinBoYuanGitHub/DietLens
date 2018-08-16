//
//  CustomPhotoAlbum.swift
//  DietLens
//
//  Created by linby on 2018/7/17.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Photos

class CustomPhotoAlbum {

    static let albumName = "DietLens"
    static let sharedInstance = CustomPhotoAlbum()

    var assetCollection: PHAssetCollection!

    init() {

        func fetchAssetCollectionForAlbum() -> PHAssetCollection! {

            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            return collection.firstObject
        }

        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }

        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)
        }) { success, _ in
            if success {
                self.assetCollection = fetchAssetCollectionForAlbum()
            }
        }
    }

    func saveImage(image: UIImage) {
        if assetCollection == nil {
            return   // If there was an error upstream, skip the save.
        }
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            guard let photoPlaceholder = assetChangeRequest.placeholderForCreatedAsset else {
                // Photo Placeholder is nil
                return
            }
            let albumChangeRequest =
                PHAssetCollectionChangeRequest(for: self.assetCollection)
            let enumeration: NSArray = [photoPlaceholder]
            albumChangeRequest?.addAssets(enumeration)
        }, completionHandler: nil)
    }

}
