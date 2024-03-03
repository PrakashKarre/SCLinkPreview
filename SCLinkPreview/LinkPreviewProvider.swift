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
    var dictionary = [String : LinkPreviewMetaData]()
    private init(){
        
    }
    public var enableCache = false
    
    func findLinkPreview(message: String, success: @escaping (_ metadata: LinkPreviewMetaData,_ url: String)->Void, failure : @escaping (_ error: LinkPreviewError)->Void){
        let urls = URLHelper.shared.findURLIn(text: message)
        if urls.isEmpty {
            return failure(.urlNotFound)
        }
        findLinkPreview(url: urls[0], success: success, failure: failure)
    }
    func findLinkPreview(url: URL, success: @escaping (_ metadata: LinkPreviewMetaData, _ url: String)->Void, failure : @escaping (_ error: LinkPreviewError)->Void){
        if let metaData =  dictionary[url.absoluteString]{
            return success(metaData,url.absoluteString)
        }
        
        let provider = LPMetadataProvider()
        var urlDup = url
        if !url.absoluteString.starts(with: "https://") {
            if url.absoluteString.starts(with: "http://"){
                urlDup = URL(string: url.absoluteString.replacingOccurrences(of: "http://", with: "https://")) ?? url
            }else{
                urlDup = URL(string: "https://"+url.absoluteString) ?? url
            }
        }
        provider.startFetchingMetadata(for: urlDup) { metadata, error in
            DispatchQueue.main.async {
                if let error = error {
                    return failure(.previewFailed(error: error.localizedDescription))
                }
                
                guard let metadata = metadata,let title = metadata.title, !title.isEmpty, let siteurl = metadata.originalURL?.host, let siteName = metadata.value(forKey: "siteName") as? String else {
                    return failure(.previewFailed(error: "Meta data not found"))
                }
               
                var linkPreviewMetaData = LinkPreviewMetaData(title: title, siteurl: siteurl, siteName: siteName)
                if let description = metadata.value(forKey: "summary") as? String{
                    linkPreviewMetaData.description = description
                }
                if let imageData = metadata.value(forKey: "imageMetadata") as? NSObject, let imageURL = imageData.value(forKey: "URL") as? URL{
                    linkPreviewMetaData.imageUrl = imageURL.absoluteString
                }
                if let iconData = metadata.value(forKey: "iconMetadata") as? NSObject, let imageURL = iconData.value(forKey: "URL") as? URL{
                    linkPreviewMetaData.imageUrl = imageURL.absoluteString
                }
                self.processMetaData(url: url, metaData: linkPreviewMetaData, handler: success)
            }
        }
    }
    fileprivate func processMetaData(url: URL, metaData: LinkPreviewMetaData, handler: (_ metadata: LinkPreviewMetaData, _ url: String)->Void ){
        self.dictionary[url.absoluteString] = metaData
        handler(metaData,url.absoluteString)
    }
}
