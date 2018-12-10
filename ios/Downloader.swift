//
//  Downloader.swift
//  deep.mobile
//
//  Created by Drake Svoboda on 11/11/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation

class Downloader : NSObject, URLSessionDownloadDelegate {
  
  var url : URL?
  var destination: URL?
  var completionHandler: ((URL) -> Void)?
  var progressHandler: ((Float) -> Void)?
  var errorHandler: ((Error?) -> Void)?
  
  override init() {
    super.init()
  }
  
  func load(from url: URL, to destination: URL, completion:  @escaping (URL) -> Void,
                progress: @escaping (Float) -> Void, error: @escaping (Error?) -> Void) {
    self.url = url
    self.destination = destination
    self.completionHandler = completion
    self.progressHandler = progress
    self.errorHandler = error
    
    //download identifier can be customized. I used the "ulr.absoluteString"
    let sessionConfig = URLSessionConfiguration.background(withIdentifier: url.absoluteString)
    let session = Foundation.URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)
    let task = session.downloadTask(with: url)
    task.resume()
  }
  
  //is called once the download is complete
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)
  {
    let dataFromURL = NSData(contentsOf: location)
    dataFromURL?.write(to: self.destination!, atomically: true)
    
    guard completionHandler != nil else { return }
    completionHandler!(self.destination!)
  }
  
  //this is to track progress
  func urlSession(_ session: URLSession,
                  downloadTask: URLSessionDownloadTask,
                  didWriteData bytesWritten: Int64,
                  totalBytesWritten: Int64,
                  totalBytesExpectedToWrite: Int64)
  {
    guard progressHandler != nil else { return }
    progressHandler!(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
  }
  
  // if there is an error during download this will be called
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
  {
    guard error != nil else { return }
    print("Download completed with error: \(error!.localizedDescription)");
    
    guard errorHandler != nil else { return }
    errorHandler!(error)
  }
}
