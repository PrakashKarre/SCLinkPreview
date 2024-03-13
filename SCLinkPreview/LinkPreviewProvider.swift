//
//  LinkPreviewProvider.swift
//  BlueSecures
//
//  Created by Apple  on 15/02/24.
//  Copyright © 2024 Sundir Kumar. All rights reserved.
//

import Foundation
import LinkPresentation
import UniformTypeIdentifiers
open class LinkPreviewProvider{
    static let shared = LinkPreviewProvider()
    var linkMetaDataStorage: LinkMetaDataStorage? = RealmLinkMetadataStorage(maxSize: 100)
    private init(){
        
    }
    public var enableCache : Bool {
        get {
            return linkMetaDataStorage != nil
        }
        set {
            linkMetaDataStorage = newValue ? RealmLinkMetadataStorage(maxSize: 100) : nil
        }
        
    }
    
    func findLinkPreviewMetaData(text: String, success: @escaping (_ metadata: LinkPreviewMetaData,_ url: String)->Void, failure : @escaping (_ error: LinkPreviewError)->Void){
        let urls = URLHelper.shared.findURLIn(text: text)
        if urls.isEmpty {
            return failure(.urlNotFound)
        }
        findLinkPreviewMetaData(url: urls[0], success: success, failure: failure)
    }
    
    func findLinkPreviewMetaData(url: URL, success: @escaping (_ metadata: LinkPreviewMetaData, _ url: String)->Void, failure : @escaping (_ error: LinkPreviewError)->Void){
        if let metaData = linkMetaDataStorage?.readMetadataFor(url: url.absoluteString){
            return success(metaData,url.absoluteString)
        }
        
        let provider = LPMetadataProvider()
        
        provider.startFetchingMetadata(for: createValidURL(url: url)) { metadata, error in
            DispatchQueue.main.async {
                if let error = error {
                    return failure(.previewFailed(error: error.localizedDescription))
                }
                guard let metadata = metadata,let title = metadata.title, !title.isEmpty, let siteurl = metadata.originalURL?.host else {
                    return failure(.metaDataFailed)
                }
                
                var linkPreviewMetaData = LinkPreviewMetaData(title: title, siteurl: siteurl)
                if let description = metadata.value(forKey: "summary") as? String{
                    linkPreviewMetaData.description = description
                }
                if let siteName = metadata.value(forKey: "siteName") as? String {
                    linkPreviewMetaData.siteName = siteName
                }
                if let imageData = metadata.value(forKey: "imageMetadata") as? NSObject, let imageURL = imageData.value(forKey: "URL") as? URL{
                    linkPreviewMetaData.imageUrl = imageURL.absoluteString
                }
                if let iconData = metadata.value(forKey: "iconMetadata") as? NSObject, let imageURL = iconData.value(forKey: "URL") as? URL{
                    linkPreviewMetaData.iconUrl = imageURL.absoluteString
                }
                self.processMetaData(url: url, metaData: linkPreviewMetaData, handler: success)
            }
        }
    }
    
    func findLinkPreview(url: URL, success: @escaping (_ preview : LPLinkView, _ url: String) -> Void, failure: @escaping(_ error: LinkPreviewError) -> Void) {
      
        let provider = LPMetadataProvider()
        provider.startFetchingMetadata(for: createValidURL(url: url)) { metadata, error in
            DispatchQueue.main.async {
                if let error = error {
                    return failure(.previewFailed(error: error.localizedDescription))
                }
                guard let metadata = metadata,let title = metadata.title, !title.isEmpty else {
                    return failure(.previewFailed(error: "Meta data not found"))
                }
                return success(LPLinkView(metadata: metadata),url.absoluteString)
            }
        }
    }
    
    func findLinkPreview(text: String, success: @escaping (_ preview: LPLinkView,_ url: String)->Void, failure : @escaping (_ error: LinkPreviewError)->Void){
        let urls = URLHelper.shared.findURLIn(text: text)
        if urls.isEmpty {
            return failure(.urlNotFound)
        }
        findLinkPreview(url: urls[0], success: success, failure: failure)
    }
    
    fileprivate func processMetaData(url: URL, metaData: LinkPreviewMetaData, handler: (_ metadata: LinkPreviewMetaData, _ url: String)->Void ){
        let urlString = url.absoluteString
        self.linkMetaDataStorage?.saveMetadataFor(url: urlString, data: metaData)
        handler(metaData,url.absoluteString)
    }
    fileprivate func createValidURL(url: URL) -> URL{
        let checkUrl = url.absoluteString.lowercased()
        if checkUrl.starts(with: "https://") {
            return url
        }
        return  checkUrl.starts(with: "http://") ? URL(string: checkUrl.replacingOccurrences(of: "http://", with: "https://")) ?? url : URL(string: "https://"+checkUrl) ?? url
    }
}
