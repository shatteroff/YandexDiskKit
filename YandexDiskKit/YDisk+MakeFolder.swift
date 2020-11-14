//
//  YDisk+MakeFolder.swift
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

extension YandexDisk {

    public enum MakeFolderResult {
        case Created(href:String, method:String, templated:Bool)
        case Failed(NSError!)
    }
    
    /// Make Folder
    ///
    /// :param: path    The path to the folder being created.
    ///   For example, to create the folder `Music` in the Disk root directory,
    ///   set the parameter value `.Disk("/Music")`.
    /// :param: handler Optional.
    /// :returns: `MakeFolderResult` future.
    ///
    /// API reference:
    ///   `english http://api.yandex.com/disk/api/reference/create-folder.xml`_,
    ///   `russian https://tech.yandex.ru/disk/api/reference/create-folder-docpage/`_.
    public func makeFolderAtPath(path:Path, handler:((_ result:MakeFolderResult) -> Void)? = nil) -> Result<MakeFolderResult> {
        let result = Result<MakeFolderResult>(handler: handler)

        var url = "\(baseURL)/v1/disk/resources?path=\(path.toUrlEncodedString)"

        let error = { result.set(result: .Failed($0)) }

        session.jsonTaskWithURL(url: url, method:"PUT", errorHandler: error) {
            (jsonRoot, response)->Void in

            switch response.statusCode {
            case 201:
                let (href, method, templated) = YandexDisk.hrefMethodTemplatedWithDictionary(dict: jsonRoot)
                return result.set(result: .Created(href: href, method: method, templated: templated))

            default:
                return error(NSError(domain: "YDisk", code: response.statusCode, userInfo: ["response":response]))
            }
        }.resume()

        return result
    }
}
