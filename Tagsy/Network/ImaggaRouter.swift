//
//  ImaggaRouter.swift
//  Tagsy
//
//  Created by jp on 2019-04-01.
//  Copyright © 2019 Jordan Perrella. All rights reserved.
//

import Alamofire

public enum ImaggaRouter: URLRequestConvertible {
  
  enum Constants {
    static let baseURL = ""
    static let authorizationToken = ""
  }
  
  case upload
  case tags(String)
  case colors(String)
  
  var method: HTTPMethod {
    switch self {
    case .upload:
      return .post
    case .tags, .colors:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .upload:
      return "/content"
    case .tags:
      return "/tagging"
    case .colors:
      return "/colors"
    }
  }
  
  var parameters: [String: Any] {
    switch self {
    case .tags(let contentID):
      return ["content": contentID]
    case .colors(let contentID):
      return ["content": contentID, "extract_object_colors": 0]
    default:
      return [:]
    }
  }
  
  public func asURLRequest() throws -> URLRequest {
    let url = try Constants.baseURL.asURL()
    
    var request = URLRequest(url: url.appendingPathComponent(path))
    request.httpMethod = method.rawValue
    request.setValue(Constants.authorizationToken, forHTTPHeaderField: "Authorization")
    request.timeoutInterval = TimeInterval(10000)
    
    return try URLEncoding.default.encode(request, with: parameters)
  }
  
}
