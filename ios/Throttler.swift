//  Throttler.swift
//
//  Created by Daniele Margutti on 10/19/2017
//
//  web: http://www.danielemargutti.com
//  email: hello@danielemargutti.com
//
//  Updated by Ignazio Calò on 19/10/2017.
//  Updated by Drake Svoboda on 10/09/20118.

import UIKit
import Foundation

public class Throttler {
  private let queue: DispatchQueue!
  private var job: DispatchWorkItem = DispatchWorkItem(block: {})
  private var previousRun: Date = Date.distantPast
  private var maxInterval: Double
  
  init(seconds: Double, queue: DispatchQueue = DispatchQueue.global(qos: .background)) {
    self.maxInterval = seconds
    self.queue = queue
  }
  
  func throttle(block: @escaping () -> ()) {
    job.cancel()
    job = DispatchWorkItem(){ [weak self] in
      self?.previousRun = Date()
      block()
    }
    let delay = Date.interval(from: previousRun) > maxInterval ? 0 : maxInterval
    queue.asyncAfter(deadline: .now() + delay, execute: job)
  }
}

private extension Date {
  static func interval(from referenceDate: Date) -> Double {
    return Date().timeIntervalSince(referenceDate).rounded()
  }
}
