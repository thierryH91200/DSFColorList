//
//  DSFColorList+Errors.swift
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

import Foundation

public extension DSFColorList {

	/// The errors thrown from the colorlist classes
	enum ColorError: Error {
		/// Tried to create a CGColorSpce with an unsupported colorspace name
		case InvalidColorSpace(String)
		/// Unable to create a CGColor from a given colorspace name and components
		case UnableToCreateColor(String, [Float])
		/// Cannot convert color to another colorspace
		case CannotConvertColorspace
		/// Couldn't convert binary data to a valid JSON string
		case UnableToEncodeJSON
		/// The provided JSON string was not using utf8 encoding
		case JSONNotUTF8
		/// An attempt to encode to binary data failed
		case UnableToEncodeData
		/// Tried to load a type of colorlist from a pasteboard which doesn't contain one
		case PasteboardDoesntContainColorlist
		/// Tried to create a named color using a SwiftUI color that couldn't be converted to CGColor
		case UnableToConvertSwiftUIColorToCGColor
	}
}
