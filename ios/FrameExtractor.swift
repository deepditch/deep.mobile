//
//  FrameExtractor.swift
//  Uses the devices camera and makes real time frames availible for processing
//
//

import AVFoundation
import UIKit
import CoreML
import Vision
import ImageIO

class FrameExtractor : NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
  private let captureSession = AVCaptureSession()
  private let sessionQueue = DispatchQueue(label: "session queue")
  private var cameraPermissionGranted = false
  private let position = AVCaptureDevice.Position.back
  private let quality = AVCaptureSession.Preset.medium
  private let context = CIContext()
  var frameCaptured: ((UIImage?) -> Void)?
  
  override init() {
    print("init")
    super.init()
    checkPermission()
    sessionQueue.async { [unowned self] in // sessionQueue might be suspended after checkPermission. unowned self prevents a possible retain cycle.
      self.configureSession()
      self.captureSession.startRunning() // Session is started on the sessionQueue, frames are processed on a separate queue
    }
  }
  
  // MARK: AVSession configuration
  private func checkPermission() {
    switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
    case .authorized:
      cameraPermissionGranted = true
      break
    case .notDetermined:
      requestPermission()
      break
    default:
      cameraPermissionGranted = false
      break
    }
  }
  
  private func requestPermission() {
    sessionQueue.suspend() // AVCaptureDevice.requestAccess is async, so we suspend and wait for a response from the user
    AVCaptureDevice.requestAccess(for: AVMediaType.video) { [unowned self] granted in
      self.cameraPermissionGranted = granted
      self.sessionQueue.resume() // Resume our queue once we have a response
    }
  }
  
  private func configureSession() {
    guard cameraPermissionGranted else { return }
    captureSession.sessionPreset = quality
    guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: position) else { return }
    guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
    guard captureSession.canAddInput(captureDeviceInput) else { return }
    captureSession.addInput(captureDeviceInput)
    let videoOutput = AVCaptureVideoDataOutput()
    videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
    guard captureSession.canAddOutput(videoOutput) else { return }
    captureSession.addOutput(videoOutput)
    guard let connection = videoOutput.connection(with: AVFoundation.AVMediaType.video) else { return }
    guard connection.isVideoOrientationSupported else { return }
    guard connection.isVideoMirroringSupported else { return }
    connection.videoOrientation = .landscapeLeft
    connection.isVideoMirrored = position == .front
  }
  
  private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
    guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
    let ciImage = CIImage(cvPixelBuffer: imageBuffer)
    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
    let img = UIImage(cgImage: cgImage, scale: 1, orientation: exifOrientationFromDeviceOrientation())
    return fixOrientation(for: img)
  }
  
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
  
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    guard let uiImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
    
    DispatchQueue.main.async { [unowned self] in // Image is sent to the delegate on the main thread.
      guard self.frameCaptured != nil else { return }
      self.frameCaptured?(uiImage)
    }
  }
  
  public func exifOrientationFromDeviceOrientation() -> UIImage.Orientation {
    let curDeviceOrientation = UIDevice.current.orientation
    let exifOrientation: UIImage.Orientation
    
    switch curDeviceOrientation {
    case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
      exifOrientation = .right
    case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
      exifOrientation = .down
    case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
      exifOrientation = .left
    case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
      exifOrientation = .up
    default:
      exifOrientation = .up
    }
    return exifOrientation
  }
}
