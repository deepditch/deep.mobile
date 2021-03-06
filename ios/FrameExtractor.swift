/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 Contains the view controller for the Breakfast Finder.
 */

import UIKit
import AVFoundation
import Vision

class FrameExtractor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
  var bufferSize: CGSize = .zero
  
  public var previewView: UIView!
  public var previewLayer: AVCaptureVideoPreviewLayer! = nil
  private let videoDataOutput = AVCaptureVideoDataOutput()
  private let session = AVCaptureSession()
  
  private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
  
  init(previewView: UIView) {
    super.init()
    self.previewView = previewView
    self.setupAVCapture()
  }
  
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    // to be implemented in the subclass
  }
  
  func setupAVCapture() {
    var deviceInput: AVCaptureDeviceInput!
    
    // Select a video device, make an input
    let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first

    
    guard videoDevice != nil else { return }
    
    do {
      deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
    } catch {
      print("Could not create video device input: \(error)")
      return
    }
    
    session.beginConfiguration()
    session.sessionPreset = .vga640x480 // Model image size is smaller.
    
    // Add a video input
    guard session.canAddInput(deviceInput) else {
      print("Could not add video device input to the session")
      session.commitConfiguration()
      return
    }
    session.addInput(deviceInput)
    if session.canAddOutput(videoDataOutput) {
      session.addOutput(videoDataOutput)
      // Add a video data output
      videoDataOutput.alwaysDiscardsLateVideoFrames = true
      videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
      videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
    } else {
      print("Could not add video data output to the session")
      session.commitConfiguration()
      return
    }

    let captureConnection = videoDataOutput.connection(with: .video)
    // Always process the frames
    captureConnection?.isEnabled = true
    do {
      try  videoDevice!.lockForConfiguration()
      let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
      bufferSize.width = CGFloat(dimensions.width)
      bufferSize.height = CGFloat(dimensions.height)
      videoDevice!.unlockForConfiguration()
    } catch {
      print(error)
    }
    session.commitConfiguration()
    previewLayer = AVCaptureVideoPreviewLayer(session: session)
    previewLayer.connection?.videoOrientation = .landscapeRight
    previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    previewLayer.frame = previewView.bounds
    previewView.layer.addSublayer(previewLayer)
  }
  
  func startCaptureSession() {
    session.startRunning()
  }
  
  // Clean up capture setup
  func teardownAVCapture() {
    previewLayer.removeFromSuperlayer()
    previewLayer = nil
  }
  
  func configureVideoOrientation() {
    if let previewLayer = self.previewLayer,
      let connection = previewLayer.connection {
      let orientation = UIDevice.current.orientation
      
      if connection.isVideoOrientationSupported,
        let videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) {
        previewLayer.frame = self.previewView.bounds
        previewLayer.connection?.videoOrientation = videoOrientation
      }
    }
  }
  
  func captureOutput(_ captureOutput: AVCaptureOutput, didDrop didDropSampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    // print("frame dropped")
  }
}

