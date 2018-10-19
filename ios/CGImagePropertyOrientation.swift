//
//  CGImageProperty.swift
//  deep.mobile
//
//  Created by Drake Svoboda on 10/19/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation
import UIKit

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
