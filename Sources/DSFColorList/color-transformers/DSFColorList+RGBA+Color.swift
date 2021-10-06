//
//  DSFColorList+RGBA+Color.swift
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

// MARK: - An RGBA transformer

#if os(macOS)
import AppKit
#else
import UIKit
#endif

public extension DSFColorList {
	/// A simple RGBA color using a generic RGB colorspace
	struct RGBATransformer: Codable, DSFColorListColorTransformer {
		/// Returns the pasteboard type for this ColorCodable
		public static func PasteboardTypeName() -> String { DSFColorListRGBAUTI }

		/// The name for the color
		public let name: String?

		/// Red component
		public let r: CGFloat
		/// Green component
		public let g: CGFloat
		/// Blue component
		public let b: CGFloat
		/// Alpha component
		public let a: CGFloat

		/// Creates a color object given the specified components
		///
		/// Internally uses the genericRGB colorspace
		public init(name: String? = nil, r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
			self.name = name
			self.r = r
			self.g = g
			self.b = b
			self.a = a
		}

		/// Create a Color object from the specified CGColor.
		///
		/// If the color cannot be converted to genericRGB returns nil
		public init(name: String? = nil, _ cgColor: CGColor) throws {
			self.name = name
			// If our color is using the system's default RGBA colorspace, just use it
			if cgColor.colorSpace?.name == CalculatedRGBColorSpaceName,
				cgColor.numberOfComponents == 4,
				let components = cgColor.components
			{
				self.r = components[0]
				self.g = components[1]
				self.b = components[2]
				self.a = components[3]
			}
			else {
				// Attempt to convert the color to our default colorspace first
				guard
					let c = cgColor.converted(to: CalculatedRGBColorSpace, intent: .defaultIntent, options: nil),
					let components = c.components,
					c.numberOfComponents == 4
				else {
					throw DSFColorList.ColorError.CannotConvertColorspace
				}
				self.r = components[0]
				self.g = components[1]
				self.b = components[2]
				self.a = components[3]
			}
		}

		/// Returns a CGColor representation of the stored color.
		///
		/// Uses the CGColorSpace.genericRGBLinear colorspace
		public var cgColor: CGColor? {
			return CGColor.Create(genericRed: self.r, green: self.g, blue: self.b, alpha: self.a)
		}

		/// Returns a CGColor representation of the color object
		public func color() throws -> CGColor {
			if let c = self.cgColor { return c }
			throw DSFColorList.ColorError.CannotConvertColorspace
		}
	}
}
