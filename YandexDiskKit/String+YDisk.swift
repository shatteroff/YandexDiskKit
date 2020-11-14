//
//  String+YDisk.swift
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

extension String {

    func urlEncoded() -> String {
        let charactersToEscape = "!*'();:@&=+$,/?%#[]\" "
        let allowedCharacters = NSCharacterSet(charactersIn: charactersToEscape).inverted
//        return self.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters) ?? self
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? self
    }

    mutating func appendOptionalURLParameter<T>(name: String, value: T?) {
        if let value = value {
//            let seperator = self.rangeOfString("?") == nil ? "?" : "&"
            let seperator = self.range(of: "?") == nil ? "?" : "&"

//            self.splice("\(seperator)\(name)=\(value)", atIndex: self.endIndex)
            self = self + "\(seperator)\(name)=\(value)"
        }
    }
}
