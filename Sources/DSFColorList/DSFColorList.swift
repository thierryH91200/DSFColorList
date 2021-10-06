//
//  DSFColorList.swift
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

/// A generic cross-platform colorlist
public class DSFColorList {
	/// Create a colorlist object
	/// - Parameters:
	///   - name: The (optional) name for the colorlist
	///   - colors: The initial colors contained within the colorlist
	public init(name: String? = nil, colors: [DSFNamedColor] = []) {
		self.name = name
		self.colors = colors
	}

	/// The colorlist name (optional)
	public var name: String?
	/// The colorlist colors
	public var colors: [DSFNamedColor]
	/// The number of colors in the colorlist
	public var count: Int { return self.colors.count }

	/// A subscript operator for retrieving colors
	public subscript(index: Int) -> DSFNamedColor {
		return self.colors[index]
	}

	/// Append a named color to the colorlist
	@inlinable public func append(_ color: DSFNamedColor) {
		self.colors.append(color)
	}

	/// Append an array of named colors to the colorlist
	@inlinable public func append(contentsOf colors: [DSFNamedColor]) {
		self.colors.append(contentsOf: colors)
	}

	/// Append a color with an optional name to the array of colors
	@inlinable public func append(name: String? = nil, _ color: CGColor) {
		self.colors.append(DSFNamedColor(name: name, color: color))
	}
}

// MARK: - Predefined color list types

public extension DSFColorList {
	/// A simple RGBA colorlist. Automatically converts colors to the system's default RGBA format during encoding
	typealias RGBA = DSFColorList.Transformer<DSFColorList.RGBATransformer>
	/// A colorlist that preserves (where possible) the colorspaces for the contained colors when encoded
	typealias Colorspace = DSFColorList.Transformer<DSFColorList.ColorSpaceTransformer>
}
