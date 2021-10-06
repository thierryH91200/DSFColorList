//
//  DSFColorList+Colorspace+Color.swift
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

#if os(macOS)
// Shared colorspace for converting to when a supplied CGColor is using an unsupported colorspace
private let ColorSpaceColorConversionColorSpace = NSColorSpace.genericRGB.cgColorSpace!
#else
// Shared colorspace for converting to when a supplied CGColor is using an unsupported colorspace
private let ColorSpaceColorConversionColorSpace = CGColorSpace(name: CGColorSpace.extendedSRGB)!
#endif

// MARK: - DSFColorList.Colorspace.Color

public extension DSFColorList {

	/// A cross-platform (macOS/iOS/tvOS) color definition
	struct ColorSpaceTransformer: DSFColorListColorTransformer {
		/// Returns the pasteboard type for this ColorCodable
		public static func PasteboardTypeName() -> String { DSFColorListColorspaceUTI }

		/// The name for the color
		public let name: String?

		/// The name of the colorspace
		public let colorspaceName: String

		/// The color's colorspace
		public let colorSpace: CGColorSpace

		/// The float components for the color in the specified colorspace
		public let components: [CGFloat]

		/// The represented color
		public let cgColor: CGColor
	}
}

public extension DSFColorList.ColorSpaceTransformer {
	/// Create a color using a colorspace name and its color components
	init(name: String? = nil, colorspaceName: String, components: [CGFloat]) throws {
		guard let colorSpace = CGColorSpace(name: colorspaceName as CFString) else {
			throw DSFColorList.ColorError.InvalidColorSpace(colorspaceName)
		}
		guard let color = CoreGraphics.CGColor(colorSpace: colorSpace, components: components) else {
			throw DSFColorList.ColorError.UnableToCreateColor(colorspaceName, components.map { Float($0) })
		}

		self.name = name
		self.colorspaceName = colorspaceName
		self.components = components
		self.colorSpace = colorSpace
		self.cgColor = color
	}
}

public extension DSFColorList.ColorSpaceTransformer {
	/// Create a color from a CGColor. If the color cannot be converted to component values returns nil.
	init(name: String? = nil, _ cgColor: CGColor) throws {
		self.name = name
		if let colorspace = cgColor.colorSpace,
			let name = colorspace.name,
			let components = cgColor.components
		{
			// We have the colorspace name and its components
			self.colorspaceName = name as String
			self.components = components
			self.colorSpace = colorspace
			self.cgColor = cgColor
		}
		else {
			// Attempt to convert to a common RGB format
			let newColorspace = ColorSpaceColorConversionColorSpace
			guard
				let newColorspaceName = newColorspace.name,
				let converted = cgColor.converted(to: newColorspace, intent: .perceptual, options: nil),
				let components = converted.components else
				{
					throw DSFColorList.ColorError.CannotConvertColorspace
				}
			self.colorspaceName = newColorspaceName as String
			self.components = components
			self.colorSpace = newColorspace
			self.cgColor = converted
		}
	}

	/// Returns a CGColor representation of this color
	func color() throws -> CGColor {
		return self.cgColor
	}
}

// MARK: - Encoding/Decoding

extension DSFColorList.ColorSpaceTransformer: Codable {

	enum CodingKeys: String, CodingKey {
		case colorspaceName
		case components
		case name
	}

	/// Decode a color from Codable content
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let name = try? container.decode(String.self, forKey: .name)
		let colorspaceName = try container.decode(String.self, forKey: .colorspaceName)
		let components = try container.decode([CGFloat].self, forKey: .components)
		do {
			try self.init(name: name, colorspaceName: colorspaceName, components: components)
		}
		catch {
			// We couldn't automatically create the CGColor from the specified name and components.
			// If we have been provided a factory block, call it to retrieve the color from the caller.
			guard let converted = DSFColorList.ColorSpaceTransformer.ColorSpaceFactoryCallback?(colorspaceName, components) else {
				throw error
			}
			try self.init(name: name, converted)
		}
	}

	/// Encode a color to Codable content
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		if let name = self.name {
			try container.encode(name, forKey: .name)
		}
		try container.encode(self.colorspaceName, forKey: .colorspaceName)
		try container.encode(self.components, forKey: .components)
	}

	/// DSFColorList fallback color converter function definition
	public typealias ColorSpaceFactoryBlock = (_ name: String, _ components: [CGFloat]) -> CGColor?

	/// An optional factory method that, if the color isn't able to be automatically imported, can be provided
	/// to map a colorspace name and components to a CGColor within your codebase.
	public static var ColorSpaceFactoryCallback: ColorSpaceFactoryBlock? = nil
}
