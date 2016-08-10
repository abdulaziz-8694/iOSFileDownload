//
//  ViewController.swift
//  PicDownload
//
//  Created by Abdul Aziz on 09/08/16.
//  Copyright © 2016 Abdul Aziz. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITextFieldDelegate, NSURLSessionDelegate,
                    NSURLSessionDownloadDelegate, UIDocumentInteractionControllerDelegate{
    
    var downloadTask: NSURLSessionDownloadTask!

    //MARK: Properties
    @IBOutlet weak var downloadLabel: UILabel!
    @IBOutlet weak var downloadURL: UITextField!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var cancelButton: UIButton!
    
    var URL:String! = ""
    
    lazy var downloadsSession: NSURLSession = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration,
                                   delegate: self, delegateQueue: nil)
        return session
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        downloadURL.delegate = self;
        progressView.setProgress(0, animated: false)
        cancelButton.enabled = false
        cancelButton.userInteractionEnabled = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: UIDocmentInteractionControllerDelegate
    
    
    
    func documentInteractionControllerViewControllerForPreview(controller:
        UIDocumentInteractionController) -> UIViewController{
        return self
    }
    
    //MARK: NSURLSessionDownloadDelegates
    
    //Callback when download is finished
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask,
                    didFinishDownloadingToURL location: NSURL) {
        dispatch_async(dispatch_get_main_queue(), {
            self.cancelButton.enabled = false
            self.cancelButton.userInteractionEnabled = false
            self.downloadButton.enabled = true
            self.downloadButton.userInteractionEnabled = true
            self.downloadLabel.text = "Download Complete";
            self.progressView.setProgress(0, animated: false);
        })
        if let originalURL = downloadTask.originalRequest?.URL?.absoluteString,
            destinationURL = localFilePathForUrl(originalURL){
            print(destinationURL)
            
            let fileManager = NSFileManager.defaultManager()
            do {
                try fileManager.removeItemAtURL(destinationURL)
            } catch {
                // Non-fatal: file probably doesn't exist
            }
            do {
                try fileManager.copyItemAtURL(location, toURL: destinationURL)
            } catch let error as NSError {
                print("Could not copy file to disk: \(error.localizedDescription)")
            }
            
            dispatch_async(dispatch_get_main_queue(), {self.showFile(destinationURL)})
        }
        
    }
    
    
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                                 totalBytesExpectedToWrite: Int64) {
        print(totalBytesExpectedToWrite);
        if (downloadTask.originalRequest?.URL?.absoluteString) != nil {
            let totalSize = NSByteCountFormatter.stringFromByteCount(totalBytesExpectedToWrite,
                                            countStyle: NSByteCountFormatterCountStyle.Binary)
            let totalSizeWritten = NSByteCountFormatter.stringFromByteCount(totalBytesWritten,
                                            countStyle:NSByteCountFormatterCountStyle.Binary)
            let progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
            
            dispatch_async(dispatch_get_main_queue(), {
                
                
                if totalBytesExpectedToWrite < 0 {
                    self.downloadLabel.text = String(format: "%@ downloaded",
                        totalSizeWritten);
                    
                    
                }
                else{
                    self.progressView.setProgress(progress, animated: true)
                    self.downloadLabel.text = String(format: "%@ of %@",
                        totalSizeWritten, totalSize);
                }
                })
        }
        
    }
    
    
    //MARK: Helper methods
    func localFilePathForUrl(previewUrl: String) -> NSURL? {
        let documentsPath = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory, .UserDomainMask, true)[0] as NSString
        if let url = NSURL(string: previewUrl),
            lastPathComponent = url.lastPathComponent {
            let fullPath = documentsPath.stringByAppendingPathComponent(lastPathComponent)
            return NSURL(fileURLWithPath:fullPath)
        }
        return nil
    }
    
    func showFile(destination: NSURL){
       
            let isFileFound:Bool? = NSFileManager.defaultManager().fileExistsAtPath(destination.path!)
            if isFileFound == true{
                let viewer = UIDocumentInteractionController(URL: destination)
                viewer.delegate = self
                viewer.presentPreviewAnimated(true)
            }
        }
    

    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //MARK: Actions
    @IBAction func startDownload(sender: UIButton) {
        downloadLabel.text = "Download Started"
        downloadButton.enabled = false
        downloadButton.userInteractionEnabled = false
        cancelButton.enabled = true
        cancelButton.userInteractionEnabled = true
        let urlString : String! = downloadURL.text
        let url:NSURL! = NSURL(string: urlString)
        
        
        if (urlString != ""){
            downloadTask = downloadsSession.downloadTaskWithURL(url)
            downloadTask.resume()
        }
        else{
            downloadButton.enabled = true
            downloadButton.userInteractionEnabled = true
            cancelButton.enabled = false
            cancelButton.userInteractionEnabled = false
            self.downloadLabel.text = "Empty URL";
        }
        
        
        
    }
    
    @IBAction func cancelDownload(sender: UIButton) {
        print("Cancelled")
        if cancelButton.enabled == true{
            print("Cancelling download");
            downloadTask.cancel()
            cancelButton.enabled = false
            cancelButton.userInteractionEnabled = false
            downloadButton.enabled = true
            downloadButton.userInteractionEnabled = true
            downloadLabel.text = "Download Cancelled"
        }
    }
    
}

