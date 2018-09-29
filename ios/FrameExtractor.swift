//
//  FrameExtractor.swift
//  Uses the devices camera and makes real time frames availible for processing
//
//  https://medium.com/ios-os-x-development/ios-camera-frames-extraction-d2c0f80ed05a
//

import AVFoundation
import UIKit

protocol FrameExtractorDelegate: class {
  func captured(image: UIImage)
}

class FrameExtractor : NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
  private let captureSession = AVCaptureSession()
  private let sessionQueue = DispatchQueue(label: "session queue")
  private var cameraPermissionGranted = false
  private let position = AVCaptureDevice.Position.front
  private let quality = AVCaptureSession.Preset.medium
  weak var delegate: FrameExtractorDelegate?
  private let context = CIContext()
  
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
    videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer")) // Self is an AVCaptureVideoDataOutputSampleBufferDelegate, frames are processed on a different queue to avoid pile up
    guard captureSession.canAddOutput(videoOutput) else { return }
    captureSession.addOutput(videoOutput)
    guard let connection = videoOutput.connection(with: AVFoundation.AVMediaType.video) else { return }
    guard connection.isVideoOrientationSupported else { return }
    guard connection.isVideoMirroringSupported else { return }
    connection.videoOrientation = .portrait
    connection.isVideoMirrored = position == .front
  }
  
  private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
    guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
    let ciImage = CIImage(cvPixelBuffer: imageBuffer)
    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
    return UIImage(cgImage: cgImage)
  }
  
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    guard let uiImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
    
    DispatchQueue.main.async { [unowned self] in // Image is sent to the delegate on the main thread. UI can be updated right away
      self.delegate?.captured(image: uiImage)
    }
  }
}
