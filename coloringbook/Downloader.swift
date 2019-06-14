//
//  HttpDownloader.swift
//  Yolafit
//
//  Created by Admin on 16/12/2016.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation

class Downloader {
    
    class func load(url: URL, to localUrl: URL, completion: @escaping () -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: url)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                }
                
                do {
                    try FileManager.default.moveItem(at: tempLocalUrl, to: localUrl) //.copyItem(at: tempLocalUrl, to: localUrl)
                    completion()
                } catch (let writeError) {
                    print("error writing file \(localUrl) : \(writeError)")
                }
            } else {
                
            }
        }
        task.resume()
    }
}
