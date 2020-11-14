//
//  YDisk+ListPublicResources.swift
//
//  Copyright (c) 2015, Clemens Auer
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

    public enum PublicResourceListingResult {
        case Listing(items:[YandexDiskResource], type:YandexDiskResourceType?, limit:Int?, offset:Int? )
        case Failed(NSError!)
    }

    /// List metainfo for public file or folder.
    ///
    /// :param: limit           Optional. The number of recently uploaded files that should be described in the response (for example, for paginated output).
    /// :param: offset          Optional. The number of resources from the top of the list that should be skipped in the response (for example, for paginated output).
    /// :param: type            Optional. The type of files to included in the list. Each file type is detected by Disk when uploading.
    /// :param: preview_size    Optional. Requested size for the previews.
    /// :param: preview_crop    Optional. If true, preview will be cropped to square.
    /// :param: handler         Optional.
    /// :returns: `ListingResult` future.
    ///
    /// API reference:
    ///   `english http://api.yandex.com/disk/api/reference/meta.xml`_,
    ///   `russian https://tech.yandex.ru/disk/api/reference/meta-docpage/`_.
    public func listPublicResources(limit:Int?=nil, offset:Int?=nil, type:YandexDiskResourceType?=nil, preview_size:PreviewSize?=nil, preview_crop:Bool?=nil, handler:((_ listing:PublicResourceListingResult) -> Void)? = nil) -> Result<PublicResourceListingResult> {
        let result = Result<PublicResourceListingResult>(handler: handler)

        var url = "\(baseURL)/v1/disk/resources/public"

        url.appendOptionalURLParameter(name: "limit", value:limit)
        url.appendOptionalURLParameter(name: "offset", value:offset)
        url.appendOptionalURLParameter(name: "type", value:type)
        url.appendOptionalURLParameter(name: "preview_size", value:preview_size)
        url.appendOptionalURLParameter(name: "preview_crop", value:preview_crop)

        let error = { result.set(result: .Failed($0)) }

        session.jsonTaskWithURL(url: url, errorHandler: error) {
            (jsonRoot, response)->Void in

            switch response.statusCode {
            case 200:
                if let items = SimpleResource.resourcesFromArray(array: jsonRoot["items"] as? NSArray)
                {
                    let limit = (jsonRoot["limit"] as? NSNumber)?.intValue
                    let offset = (jsonRoot["offset"] as? NSNumber)?.intValue
                    let type : YandexDiskResourceType?
                    if let typestr = jsonRoot["type"] as? String {
                        type = YandexDiskResourceType(rawValue: typestr)
                    } else {
                        type = nil
                    }

                    return result.set(result: .Listing(items: items, type: type, limit: limit, offset: offset))
                } else {
                    return error(NSError(domain: "YDisk", code: response.statusCode, userInfo:
                        ["message":"incomplete JSON response", "json":jsonRoot]))
                }
            default:
                return error(NSError(domain: "YDisk", code: response.statusCode, userInfo: ["response":response]))
            }
        }.resume()

        return result
    }
}
