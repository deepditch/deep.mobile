//
//  MLModelService.swift
//  deep.mobile
//
//  Created by Drake Svoboda on 11/15/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation
import Moya
import CoreML

struct MLModelResponse: Decodable {
  struct MLModelResponseData: Decodable {
    let url: String?
  }
  
  let data: MLModelResponseData?
}

class MLModelService {
  var apiProvider: MoyaProvider<APIHTTPService>!
  let PlistFileName: String = "MlModelCache.plist"
  let CachedModelURLKey: String = "CachedModelUrl"
  var CachedModelURL: String = ""
  
  init() {
    apiProvider = MakeApiProvider()
    CachedModelURL = loadCachedModelUrl()
  }
  
  // Load the cached model url from MlModelCache.plist
  func loadCachedModelUrl() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
    let documentsDirectory = paths.object(at: 0) as! NSString
    let path = documentsDirectory.appendingPathComponent(PlistFileName)
    
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: path) {
      
      guard let bundlePath = Bundle.main.path(forResource: "MlModelCache", ofType: "plist") else { return CachedModelURL } // return the default
      
      do {
        try fileManager.copyItem(atPath: bundlePath, toPath: path)
      } catch let error as Error {
        print("Unable to copy file. ERROR: \(error.localizedDescription)")
      }
    }
    
    let resultDictionary = NSMutableDictionary(contentsOfFile: path)
    
    print("Loaded MlModelCache file is --> \(resultDictionary?.description ?? "")")
    
    let myDict = NSDictionary(contentsOfFile: path)
    
    if let dict = myDict {
      return dict.object(forKey: CachedModelURLKey) as! String // Return the saved model
    } else {
      print("WARNING: Couldn't create dictionary from MlModelCache! Default values will be used!")
    }
    
    return CachedModelURL // return the default
  }
  
  // Update the cached model url saved in MlModelCache.plist
  func updatedCachedModelUrl(with url: String, errorHandler: @escaping (Error?) -> Void) {
    
    // Delete the previously cached model
    let fileManager = FileManager.default
    if self.CachedModelURL != "", fileManager.fileExists(atPath: self.CachedModelURL) {
      do {
        try fileManager.removeItem(atPath: self.CachedModelURL)
      } catch let error as Error {
        print(error)
        errorHandler(error)
      }
    }
    
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
    let documentsDirectory = paths.object(at: 0) as! NSString
    let path = documentsDirectory.appendingPathComponent(PlistFileName)
    let dict: NSMutableDictionary = ["XInitializerItem": "DoNotEverChangeMe"]
    dict.setObject(url, forKey: CachedModelURLKey as NSCopying)
    dict.write(toFile: path, atomically: false)
    let resultDictionary = NSMutableDictionary(contentsOfFile: path)
    print("Saved MlModelCache.plist file is --> \(resultDictionary?.description ?? "")")
  }
  
  // Is the urlString newer than our cached model. Compare file names without extensions
  func shouldDownloadNewModel(at urlString: String) -> Bool {
    let fileManager = FileManager.default
    let cachedModelDoesNotExist = !fileManager.fileExists(atPath: CachedModelURL)
    let modelFromServerIsNew = NSURL(fileURLWithPath: urlString).deletingPathExtension?.lastPathComponent ?? "" != NSURL(fileURLWithPath: CachedModelURL).deletingPathExtension?.lastPathComponent ?? ""
    
    return cachedModelDoesNotExist || modelFromServerIsNew
  }
  
  // Retruns the local URL of the cached model
  func getCachedMlModelUrl() -> URL {
    return URL(fileURLWithPath: CachedModelURL);
  }
  
  // Gets the url string of the latest model stored on the server, calls completion with the url string
  func getMlModelUrlFromServer(completion: @escaping (String) -> Void, errorHandler: @escaping (Error?) -> Void) {
    apiProvider.request(.getModel()) { result in
      switch result {
      case let .success(response):
        do {
          let filteredResponse = try response.filterSuccessfulStatusCodes()
          let responseData = try filteredResponse.map(MLModelResponse.self) // user is of type User
          completion(responseData.data!.url!)
        } catch let error as Error {
          print(error)
          errorHandler(error)
        }
      case let .failure(error): // Server did not recieve request, or server did not send response
        print(error)
        errorHandler(error)
      }
    }
  }
  
  // Downloads and compiles the model stored on the server at urlString, calls completion with the compiled model url
  func downloadAndCompileMlModel(at urlString: String, completion: @escaping (URL) -> Void, progress: @escaping (Float) -> Void, errorHandler: @escaping (Error?) -> Void) {
    if let url = NSURL(string: urlString) {
      let modelUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(url.lastPathComponent!)
      Downloader().load(from: url as URL, to: modelUrl,
        completion: { localUrl in
          do {
            // The downloaded .mlmodel file needs to be compiled to a .modelrc file
            let compiledUrl = try MLModel.compileModel(at: localUrl)
            self.saveCompiledMlModel(at: compiledUrl, completion: completion, errorHandler: errorHandler)
          } catch let error as Error {
            print(error)
            errorHandler(error)
          }
        },
        progress: progress,
        error: errorHandler)
    }
  }
  
  // Saves the model locally and updates the cache, calls completion with the saved local url
  func saveCompiledMlModel(at compiledUrl: URL, completion: @escaping (URL) -> Void, errorHandler: @escaping (Error?) -> Void) {
    let fileManager = FileManager.default
    let appSupportDirectory = try! fileManager.url(for: .applicationSupportDirectory,
                                                   in: .userDomainMask, appropriateFor: compiledUrl, create: true)
    // create a permanent URL in the app support directory
    let permanentUrl = appSupportDirectory.appendingPathComponent(compiledUrl.lastPathComponent)
    
    do {
      // if the file exists, replace it. Otherwise, copy the file to the destination.
      if fileManager.fileExists(atPath: permanentUrl.path) {
        _ = try fileManager.replaceItemAt(permanentUrl, withItemAt: compiledUrl)
      } else {
        try fileManager.copyItem(at: compiledUrl, to: permanentUrl)
      }
      
      // Update the url for the cached model
      self.updatedCachedModelUrl(with: permanentUrl.path, errorHandler: errorHandler)
      
      // Call completion with local url
      completion(permanentUrl)
    } catch let error as Error {
      print("Error during copy: \(error.localizedDescription)")
      errorHandler(error)
    }
  }
  
  // Calls the completion handler with either the cached modelrc file or a new modelrc file downloaded from the server
  // The progress handler is called with download progress if a new model is downloaded
  func getModel(completion: @escaping (URL) -> Void, progress: @escaping (Float) -> Void, errorHandler: @escaping (Error?) -> Void) {
    getMlModelUrlFromServer(completion: { urlString in
      if self.shouldDownloadNewModel(at: urlString) {
        self.downloadAndCompileMlModel(at: urlString, completion: completion, progress: progress, errorHandler: errorHandler)
      } else {
        completion(self.getCachedMlModelUrl())
      }
    }, errorHandler: errorHandler)
  }
}

