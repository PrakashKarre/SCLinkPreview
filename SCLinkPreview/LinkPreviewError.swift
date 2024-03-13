//
//  LinkPreviewError.swift
//  BlueSecures
//
//  Created by Apple  on 15/02/24.
//  Copyright © 2024 Sundir Kumar. All rights reserved.
//

import Foundation
enum LinkPreviewError : Equatable{
    case urlNotFound
    case metaDataFailed
    case previewFailed(error:String)
    
}
