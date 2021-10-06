//
//  DSFColorList+Encoding.swift
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

import CoreGraphics
import Foundation

#if os(macOS)
import AppKit
#endif

// MARK: - Encoding

public extension DSFColorList {
	/// Encode the colorlist using the specified color encoder
	/// - Parameters:
	///   - encoderType: The type of encoder to use when encoding
	/// - Returns: The binary data for the encoded object
	///
	/// Usage:
	///
	/// ```swift
	/// let data = try DSFColorList(...).encode(DSFColorList.RGBAColorCodable.self)
	/// ```
	func encode<EncoderType: DSFColorListColorTransformer>(_ encoderType: EncoderType.Type) throws -> Data {
		let e = DSFColorList.Transformer<EncoderType>(name: self.name, colors: self.colors)
		return try JSONEncoder().encode(e)
	}

	/// Encode the colorlist as a JSON-formatted string using the specified color encoder
	/// - Parameters:
	///   - encoderType: The type of encoder to use when encoding
	/// - Returns: The json string for the encoded object
	///
	/// Usage:
	///
	/// ```swift
	/// let jsonString = try DSFColorList(...).encodeJSON(DSFColorList.RGBAColorCodable.self)
	/// ```
	func encodeJSON<EncoderType: DSFColorListColorTransformer>(_ encoderType: EncoderType.Type) throws -> String {
		let data = try self.encode(encoderType)
		guard let strVal = String(data: data, encoding: .utf8) else {
			throw DSFColorList.ColorError.UnableToEncodeJSON
		}
		return strVal
	}
}

// MARK: - Decoding

public extension DSFColorList {
	/// Create a colorlist object by decoding the data using the specified ColorCoder
	/// - Parameters:
	///   - decoderType: The type of decoder to use when encoding
	///   - data: The input data
	/// - Returns: The colorlist contained within data
	///
	/// Usage:
	/// ```swift
	/// let colorList = try DSFColorList.Decode(DSFColorList.RGBAColorCodable.self, data: inputData))
	/// ```
	static func Decode<DecoderType: DSFColorListColorTransformer>(_ decoderType: DecoderType.Type, data: Data) throws -> DSFColorList {
		return try DSFColorList.Transformer<DecoderType>(data: data)
	}

	/// Create a colorlist object by decoding the json string using the specified DSFColorListColorTransformer
	/// - Parameters:
	///   - encoderType: The type of encoder to use when encoding
	///   - jsonString: The input json string
	/// - Returns: The json string for the encoded object
	///
	/// Usage:
	/// ```swift
	/// let colorList = try DSFColorList.Decode(DSFColorList.RGBAColorCodable.self, data: inputData))
	/// ```
	static func Decode<DecoderType: DSFColorListColorTransformer>(_ decoderType: DecoderType.Type, jsonString: String) throws -> DSFColorList {
		guard let data = jsonString.data(using: .utf8) else {
			throw DSFColorList.ColorError.JSONNotUTF8
		}
		return try DSFColorList.Transformer<DecoderType>(data: data)
	}
}

// MARK: - Attempt to decode from any DSFColorList encoded format

public extension DSFColorList {
	/// Attempt to decode json-encoded data using one of our known DSFColorListColorTransformer types
	/// - Parameter data: The data containing the
	/// - Returns: A colorlist object if we were able to decode one of our known types from the data, or nil if a
	///              colorlist could not be decoded
	static func Decode(data: Data) -> DSFColorList? {
		if let d = try? DSFColorList.RGBA(data: data) {
			return d
		}
		if let d = try? DSFColorList.Colorspace(data: data) {
			return d
		}
#if os(macOS)
		if let d = try? NSColorList.Decode(from: data) {
			return try? DSFColorList(d)
		}
#endif
		return nil
	}

	/// Attempt to decode a json string using one of our known DSFColorListColorTransformer types
	/// - Parameter data: The data containing the
	/// - Returns: A colorlist object if we were able to decode one of our known types from the data, or nil if a
	///              colorlist could not be decoded
	static func Decode(jsonString: String) throws -> DSFColorList? {
		guard let data = jsonString.data(using: .utf8) else {
			throw DSFColorList.ColorError.JSONNotUTF8
		}
		return Self.Decode(data: data)
	}
}
