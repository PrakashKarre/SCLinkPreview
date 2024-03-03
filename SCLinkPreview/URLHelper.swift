//
//  URLHelper.swift
//  BlueSecures
//
//  Created by Apple  on 15/02/24.
//  Copyright © 2024 Sundir Kumar. All rights reserved.
//

import Foundation
class URLHelper{
    static let shared = URLHelper()
    
    private init(){
        
    }
    func findURLIn(text : String) -> [URL]{
        var urls = [URL]()
        do{
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
            for match in matches {
                if let url = match.url {
                    urls.append(url)
                }
            }
        }catch {
            
        }
        return urls
    }
}
