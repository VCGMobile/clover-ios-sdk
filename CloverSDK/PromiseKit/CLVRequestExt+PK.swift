//
//  CLVRequestExt+PK.swift
//  CloverDashboard
//
//  Created by Yusuf on 12/7/15.
//  Copyright © 2015 Clover Network, Inc. All rights reserved.
//

import Alamofire
import SwiftyJSON
import ObjectMapper
import PromiseKit

extension CLVRequest {
  
  // note: objectType and arrayType optional parameters are necessary for some cases where the compiler cannot infer the type
  
  /// Get a single Clover object using a RETRIEVE endpoint
  public func makeRequestObjWithPromise<T: Mappable>(objectType: T.Type = T.self) -> Promise<T> {
    return Promise { fulfill, reject in
      makeRequestAndGetResponseValidation() { validation in
        switch validation {
        case .SUCCESS(let value): fulfill(self.mapObject(value)!)
        case .FAILURE(let error): reject(error)
        case .UNAUTHORIZED_EXCEPTION_401: reject(CLVError.unauthorizedException)
        case .TOO_MANY_REQUESTS_EXCEPTION_429:
          if CLVRequest.retryFailedRequestsWith429 { self.makeRequestObjWithPromise(0, fulfill, reject) }
          else { reject(CLVError.tooManyRequestsException) }
        }
      }
    }
  }
  
  fileprivate func makeRequestObjWithPromise<T: Mappable>(_ retryCount: Int, _ fulfill: @escaping (T) -> Void, _ reject: @escaping (Error) -> Void) {
    log429(retryCount)
    do_after(seconds: (2**retryCount) + 0.1) {
      self.makeRequestAndGetResponseValidation() { validation in
        switch validation {
        case .SUCCESS(let value): fulfill(self.mapObject(value)!); self.log429Success(retryCount)
        case .FAILURE(let error): reject(error)
        case .UNAUTHORIZED_EXCEPTION_401: reject(CLVError.unauthorizedException)
        case .TOO_MANY_REQUESTS_EXCEPTION_429:
          if retryCount < CLVRequest.retryCountAfter429 { self.makeRequestObjWithPromise(retryCount + 1, fulfill, reject) }
          else { reject(CLVError.tooManyRequestsException) }
        }
      }
    }
  }
  
  /// Get an array of Clover objects using a LIST endpoint
  public func makeRequestArrWithPromise<T: Mappable>(arrayType: T.Type = T.self) -> Promise<[T]> {
    return Promise { fulfill, reject in
      makeRequestAndGetResponseValidation() { validation in
        switch validation {
        case .SUCCESS(let value): fulfill(self.mapArray(value))
        case .FAILURE(let error): reject(error)
        case .UNAUTHORIZED_EXCEPTION_401: reject(CLVError.unauthorizedException)
        case .TOO_MANY_REQUESTS_EXCEPTION_429:
          if CLVRequest.retryFailedRequestsWith429 { self.makeRequestArrWithPromise(0, fulfill, reject) }
          else { reject(CLVError.tooManyRequestsException) }
        }
      }
    }
  }
  
  fileprivate func makeRequestArrWithPromise<T: Mappable>(_ retryCount: Int, _ fulfill: @escaping ([T]) -> Void, _ reject: @escaping (Error) -> Void) {
    log429(retryCount)
    do_after(seconds: (2**retryCount) + 0.1) {
      self.makeRequestAndGetResponseValidation() { validation in
        switch validation {
        case .SUCCESS(let value): fulfill(self.mapArray(value)); self.log429Success(retryCount)
        case .FAILURE(let error): reject(error)
        case .UNAUTHORIZED_EXCEPTION_401: reject(CLVError.unauthorizedException)
        case .TOO_MANY_REQUESTS_EXCEPTION_429:
          if retryCount < CLVRequest.retryCountAfter429 { self.makeRequestArrWithPromise(retryCount + 1, fulfill, reject) }
          else { reject(CLVError.tooManyRequestsException) }
        }
      }
    }
  }
  
  /// Get AnyObject
  public func makeRequestWithPromise() -> Promise<AnyObject> {
    return Promise { fulfill, reject in
      makeRequestAndGetResponseValidation() { validation in
        switch validation {
        case .SUCCESS(let value): fulfill(self.mapAnyObject(value))
        case .FAILURE(let error): reject(error)
        case .UNAUTHORIZED_EXCEPTION_401: reject(CLVError.unauthorizedException)
        case .TOO_MANY_REQUESTS_EXCEPTION_429:
          if CLVRequest.retryFailedRequestsWith429 { self.makeRequestWithPromise(0, fulfill, reject) }
          else { reject(CLVError.tooManyRequestsException) }
        }
      }
    }
  }
  
  fileprivate func makeRequestWithPromise(_ retryCount: Int, _ fulfill: @escaping (AnyObject) -> Void, _ reject: @escaping (Error) -> Void) {
    log429(retryCount)
    do_after(seconds: (2**retryCount) + 0.1) {
      self.makeRequestAndGetResponseValidation() { validation in
        switch validation {
        case .SUCCESS(let value): fulfill(self.mapAnyObject(value)); self.log429Success(retryCount)
        case .FAILURE(let error): reject(error)
        case .UNAUTHORIZED_EXCEPTION_401: reject(CLVError.unauthorizedException)
        case .TOO_MANY_REQUESTS_EXCEPTION_429:
          if retryCount < CLVRequest.retryCountAfter429 { self.makeRequestWithPromise(retryCount + 1, fulfill, reject) }
          else { reject(CLVError.tooManyRequestsException) }
        }
      }
    }
  }
  
}
