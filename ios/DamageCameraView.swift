//
//  ViewController.swift
//  RealTimeCamera
//  A view that dispalays camera frames in real time
//
//  Created by Drake Svoboda on 9/28/18.
//  Copyright © 2018 Drake Svoboda. All rights reserved.
//

import UIKit

class DamageCameraView: UIImageView, FrameExtractorDelegate {
  var frameExtractor: FrameExtractor!
  
  init() {
    super.init(image: nil)
    frameExtractor = FrameExtractor()
    frameExtractor.delegate = self // self recieves each frame from the frame extractor
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func captured(image: UIImage) {
    self.image = image
  }
}

