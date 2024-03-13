//
//  RealmLinkMetadataModel.swift
//  SCLinkPreview
//
//  Created by Apple  on 11/03/24.
//

import Foundation
import RealmSwift
class RealmLinkMetadataModel: Object{
    @Persisted(primaryKey: true) var url: String
    @Persisted var title: String
    @Persisted var details: String?
    @Persisted var imageUrl: String?
    @Persisted var siteurl: String
    @Persisted var siteName:String?
    @Persisted var iconUrl: String?
    @Persisted var lastUsedTime: Date = Date()
}
