//
//  RealmLinkMetadataStorage.swift
//  SCLinkPreview
//
//  Created by Apple  on 11/03/24.
//

import Foundation
import RealmSwift
class RealmLinkMetadataStorage : LinkMetaDataStorage {
    var maxSize: Int
    
    init(maxSize: Int) {
        self.maxSize = maxSize
    }
    let realm = try! Realm()
    
    func readMetadataFor(url: String) -> LinkPreviewMetaData? {
        guard let saved = realm.object(ofType: RealmLinkMetadataModel.self, forPrimaryKey: url) else{
            return nil
        }
        try! realm.write {
            saved.lastUsedTime = Date()
        }
        
        self.evictInNeeded()
        
        return prepareModel(from: saved)
    }
    
    func saveMetadataFor(url: String, data: LinkPreviewMetaData) {
        let object = prepareModel(from: data,url: url)
        try! realm.write {
            realm.add(object, update: .modified)
        }
    }
    
    func evictInNeeded() {
        DispatchQueue.global().async {
            let realm = try! Realm()
            let items = realm.objects(RealmLinkMetadataModel.self).sorted(byKeyPath: "lastUsedTime", ascending: false)
            if items.count > self.maxSize {
                let itemsToRemove = items.prefix(items.count - self.maxSize)
                try! realm.write {
                    realm.delete(itemsToRemove)
                }
            }
        }
        
    }
    
    func readMetadataFor(url: [String]) -> [LinkPreviewMetaData] {
        let predicate = NSPredicate(format: RealmLinkMetadataModel().url.description, argumentArray: url)
        let objects = realm.objects(RealmLinkMetadataModel.self).filter(predicate)
        return objects.map { object in
            return prepareModel(from: object)
        }
    }
    fileprivate func prepareModel(from metadata : LinkPreviewMetaData,url: String) -> RealmLinkMetadataModel{
        let object = RealmLinkMetadataModel()
        object.url = url
        object.title = metadata.title
        object.details = metadata.description ?? nil
        object.imageUrl = metadata.imageUrl ?? nil
        object.siteurl = metadata.siteurl
        object.siteName = metadata.siteName ?? nil
        object.iconUrl = metadata.iconUrl ?? nil
        return object
    }
    fileprivate func prepareModel(from model : RealmLinkMetadataModel) -> LinkPreviewMetaData{
        var metaData = LinkPreviewMetaData(title: model.title, siteurl: model.siteurl)
        metaData.description = model.details
        metaData.imageUrl = model.imageUrl
        metaData.siteName = model.siteName
        metaData.iconUrl = model.iconUrl
        return metaData
    }
    
}
extension KeyPath where Root: AnyObject {
    var propertyName: String {
        return NSExpression(forKeyPath: self).keyPath
    }
}
