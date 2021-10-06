//
//  DSFColorList+Codable.swift
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
#else
import UIKit
#endif

public extension DSFColorList {
	/// A codable colorlist class that uses a specific color transformer
	///
	/// ```swift
	/// struct MyObject: Codable {
	///    let title: String
	///    let colorList: DSFColorList.Transformer<DSFColorList.RGBATransformer>
	/// }
	/// ```
	class Transformer<CodableColorType: DSFColorListColorTransformer>: DSFColorList, Codable {
		enum CodingKeys: String, CodingKey {
			case name
			case colors
		}

		/// Create a new colorlist
		/// - Parameters:
		///   - name: (Optional) The name of the colorlist
		///   - colors: The colors to set in the colorlist
		override public init(name: String? = nil, colors: [DSFNamedColor] = []) {
			super.init(name: name, colors: colors)
		}

		/// Create a new colorlist
		/// - Parameters:
		///   - name: (Optional) The name of the colorlist
		///   - colors: The colors to set in the colorlist
		public init(name: String? = nil, colors: [CGColor]) {
			super.init(name: name, colors: colors.map { DSFNamedColor(color: $0) })
		}

		/// Decode a colorlist of the specified type
		public required init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			let name = try? container.decode(String.self, forKey: .name)
			let dec = try container.decode([CodableColorType].self, forKey: .colors)
			let colors = try dec.compactMap { try DSFNamedColor(name: $0.name, color: $0.color()) }
			super.init(name: name, colors: colors)
		}

		/// Create a new colorlist from a JSON string
		public required convenience init(jsonString: String) throws {
			guard let data = jsonString.data(using: .utf8) else { throw DSFColorList.ColorError.UnableToEncodeJSON }
			try self.init(data: data)
		}
	}
}

// MARK: - Data encoding/decoding

public extension DSFColorList.Transformer {
	/// Create a new colorlist object from the encoded data, using the CodableColorType
	/// - Parameter data: The data to decode
	convenience init(data: Data) throws {
		let list = try JSONDecoder().decode(Transformer<CodableColorType>.self, from: data)
		self.init(name: list.name, colors: list.colors)
	}

	/// Encode the colorlist for the current color transformer
	func encodeData() throws -> Data {
		try JSONEncoder().encode(self)
	}
}

// MARK: - JSON encoding/decoding

public extension DSFColorList.Transformer {
	func encode(to encoder: Encoder) throws {
		let enc = try colors.compactMap { try CodableColorType(name: $0.name, $0.color) }
		var container = encoder.container(keyedBy: CodingKeys.self)
		if let n = self.name {
			try container.encode(n, forKey: .name)
		}
		try container.encode(enc, forKey: .colors)
	}

	func encodeJSON() throws -> String {
		let data = try JSONEncoder().encode(self)
		guard let s = String(data: data, encoding: .utf8) else {
			throw DSFColorList.ColorError.UnableToEncodeJSON
		}
		return s
	}
}
