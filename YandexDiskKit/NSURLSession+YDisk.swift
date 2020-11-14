//
//  NSURLSession+YDisk.swift
//
//  Copyright (c) 2014-2015, Clemens Auer
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import Foundation

extension URLSession {

    func jsonTaskWithURL(url: String, method:String = "GET", body:NSData?=nil, errorHandler: @escaping ((NSError?) -> Void), completionHandler: @escaping ((NSDictionary, HTTPURLResponse) -> Void)) -> URLSessionDataTask {
        let request = NSMutableURLRequest()
        request.url = NSURL(string: url) as URL?
        request.httpMethod = method
        return jsonTaskWithRequest(request: request, body: body, errorHandler: errorHandler, completionHandler: completionHandler)
    }

    func jsonTaskWithRequest(request: NSURLRequest, body:NSData?=nil, errorHandler: @escaping ((NSError?) -> Void), completionHandler: @escaping ((NSDictionary, HTTPURLResponse) -> Void)) -> URLSessionDataTask {

        let requestBody = body ?? NSData()

        return uploadTask(with: request as URLRequest, from: requestBody as Data) {
            (data, response, error)->Void in

            if error != nil {
                return errorHandler(error as NSError?)
            }

            if let response = response as? HTTPURLResponse {
                
                if let jsonRoot = YandexDisk.JSONDictionaryWithData(data: data as NSData?, errorHandler:errorHandler) {
                    switch response.statusCode {
                    case 400...599:
                        return errorHandler(NSError(domain: "YDisk", code: response.statusCode, userInfo: ["response":response, "json":jsonRoot]))
                    default:
                        return completionHandler(jsonRoot, response)
                    }
                } else {
                    return   // handler already called from JSONDictionaryWithData
                }
            } else {
                return errorHandler(NSError(domain: "YDisk", code: 0, userInfo: ["message":"Response object missing."]))
            }
        }
    }
}
