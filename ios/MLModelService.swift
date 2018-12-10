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
  
  init(with token: String) {
    apiProvider = MakeApiProvider(with: token)
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
      } catch let error as NSError {
        print("Unable to copy file. ERROR: \(error.localizedDescription)")
      }
    }
    
    let resultDictionary = NSMutableDictionary(contentsOfFile: path)
    
    print("Loaded MlModelCache file is --> \(resultDictionary?.description ?? "")")
    
    let myDict = NSDictionary(contentsOfFile: path)
    
    if let dict = myDict {
      return dict.object(forKey: CachedModelURLKey) as! String
    } else {
      print("WARNING: Couldn't create dictionary from MlModelCache! Default values will be used!")
    }
    
    return CachedModelURL // return the default
  }
  
  // Update the cached model url saved in MlModelCache.plist
  func updatedCachedModelUrl(with url: String) {
    
    // Delete the previously cached model
    let fileManager = FileManager.default
    if self.CachedModelURL != "", fileManager.fileExists(atPath: self.CachedModelURL) {
      do {
        try fileManager.removeItem(atPath: self.CachedModelURL)
      } catch let error {
        print(error);
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
  
  // Gets the url string of the latest model stored on the server, calls completion with the url string retrieved from the server
  func getMlModelUrlFromServer(completion: @escaping (String) -> Void) {
    apiProvider.request(.getModel()) { result in
      switch result {
      case let .success(response):
        do {
          let filteredResponse = try response.filterSuccessfulStatusCodes()
          let responseData = try filteredResponse.map(MLModelResponse.self) // user is of type User
          completion(responseData.data!.url!)
        } catch let error {
          print(error)
        }
      case let .failure(error): // Server did not recieve request, or server did not send response
        print(error);
      }
    }
  }
  
  // Downloads and compiles the model stored on the server at urlString, calls completion with the compiled model url
  func downloadAndCompileMlModel(at urlString: String, completion: @escaping (URL) -> Void,
                                 progress: @escaping (Float) -> Void, error: @escaping (Error?) -> Void) {
    if let url = NSURL(string: urlString) {
      let modelUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(url.lastPathComponent!)
      Downloader().load(from: url as URL, to: modelUrl,
        completion: { localUrl in
          do {
            let compiledUrl = try MLModel.compileModel(at: localUrl)
            completion(compiledUrl)
          } catch let error {
            print(error)
          }
        },
        progress: progress,
        error: error)
    }
  }
  
  // Saves the model locally and updates the cache, calls completion with the saved local url
  func saveCompiledMlModel(at compiledUrl: URL, completion: @escaping (URL) -> Void) {
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
      self.updatedCachedModelUrl(with: permanentUrl.path)
      
      // Call completion with local url
      completion(permanentUrl)
    } catch let error {
      print("Error during copy: \(error.localizedDescription)")
    }
  }
  
  // Calls completion with either the cached modelrc file or a new modelrc file downloaded from the server
  func getModel(completion: @escaping (URL) -> Void,
                progress: @escaping (Float) -> Void, error: @escaping (Error?) -> Void) {
    getMlModelUrlFromServer() { urlString in
      if self.shouldDownloadNewModel(at: urlString) {
        self.downloadAndCompileMlModel(at: urlString,
          completion: { compiledUrl in
            self.saveCompiledMlModel(at: compiledUrl) { localUrl in
              completion(localUrl)
            }
          },
          progress: progress,
          error: error)
      } else {
        completion(self.getCachedMlModelUrl())
      }
    }
  }
}

