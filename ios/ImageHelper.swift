//
//  ImageHelpers.swift
//  deep.mobile
//
//  Created by Drake Svoboda on 12/7/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class ImageHelper {
  private let context = CIContext()
  
  func fixOrientation(for img: UIImage) -> UIImage {
    if (img.imageOrientation == .up) {
      return img
    }
    
    UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
    let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
    img.draw(in: rect)
    
    let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    
    return normalizedImage
  }
  
  func imageFromBuffer(imageBuffer: CVPixelBuffer) -> UIImage? {
    let ciImage = CIImage(cvPixelBuffer: imageBuffer)
    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
    let img = UIImage(cgImage: cgImage, scale: 1, orientation: UIImageOrientationFromDeviceOrientation())
    return fixOrientation(for: img)
  }
}

func UIImageOrientationFromDeviceOrientation() -> UIImage.Orientation {
  let curDeviceOrientation = UIDevice.current.orientation
  let exifOrientation: UIImage.Orientation
  
  switch curDeviceOrientation {
  case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
    exifOrientation = .left
  case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
    exifOrientation = .up
  case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
    exifOrientation = .right
  case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
    exifOrientation = .down
  default:
    exifOrientation = .up
  }
  return exifOrientation
}

func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
  let curDeviceOrientation = UIDevice.current.orientation
  let exifOrientation: CGImagePropertyOrientation
  
  switch curDeviceOrientation {
  case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
    exifOrientation = .left
  case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
    exifOrientation = .upMirrored
  case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
    exifOrientation = .down
  case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
    exifOrientation = .up
  default:
    exifOrientation = .up
  }
  return exifOrientation
}

extension CGImagePropertyOrientation {
  /**
   Converts a `UIImageOrientation` to a corresponding
   `CGImagePropertyOrientation`. The cases for each
   orientation are represented by different raw values.
   
   - Tag: ConvertOrientation
   */
  init(_ orientation: UIImage.Orientation) {
    switch orientation {
    case .up: self = .up
    case .upMirrored: self = .upMirrored
    case .down: self = .down
    case .downMirrored: self = .downMirrored
    case .left: self = .left
    case .leftMirrored: self = .leftMirrored
    case .right: self = .right
    case .rightMirrored: self = .rightMirrored
    }
  }
}

