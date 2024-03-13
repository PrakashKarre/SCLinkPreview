//
//  LinkMetaDataStorage.swift
//  SCLinkPreview
//
//  Created by Apple  on 11/03/24.
//

import Foundation
protocol LinkMetaDataStorage{
    var maxSize: Int { set get  }
    func readMetadataFor(url: String) -> LinkPreviewMetaData?
    func saveMetadataFor(url: String, data: LinkPreviewMetaData)
    func evictInNeeded()
    func readMetadataFor(url: [String]) -> [LinkPreviewMetaData]    
}
