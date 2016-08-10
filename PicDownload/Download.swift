//
//  Download.swift
//  PicDownload
//
//  Created by Abdul Aziz on 09/08/16.
//  Copyright © 2016 Abdul Aziz. All rights reserved.
//

import Foundation

class Download: NSObject {
    var url: String;
    var isDownloading = false;
    var progress: Float = 0.0;
    
    var downloadTask: NSURLSessionDownloadTask?;
    var resumeData: NSData?;
    
    init(url: String) {
        self.url = url;
    }
}
