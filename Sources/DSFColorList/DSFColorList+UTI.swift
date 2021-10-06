//
//  DSFColorList+UTI.swift
//
//  Created by Darren Ford on 6/11/21.
//  Copyright © 2021 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

// MARK: - Uniform Type Identifiers for colorlists

import Foundation
import UniformTypeIdentifiers

/// RGBA UTI - conforms to public.json
public let DSFColorListRGBAUTI = "public.dagronf.colorlist.rgba.json.utf8"
/// Colorspace UTI - conforms to public.json
public let DSFColorListColorspaceUTI = "public.dagronf.colorlist.colorspace.json.utf8"

@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
public extension UTType {
	/// RGBA UTI - conforms to public.json
	static var colorListRGBA: UTType {
		UTType(importedAs: DSFColorListRGBAUTI, conformingTo: .json)
	}
	/// Colorspace UTI - conforms to public.json
	static var colorListColorspace: UTType {
		UTType(importedAs: DSFColorListColorspaceUTI, conformingTo: .json)
	}
}
