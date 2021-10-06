//
//  DSFColorList+Util.swift
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
import CoreGraphics

let GenericRGBAColorSpaceName = "kCGColorSpaceGenericRGB" as CFString
let GenericRGBAColorSpace = CGColorSpace(name: GenericRGBAColorSpaceName)!

/// The default color space for a single RGBA color
let CalculatedRGBColorSpace: CGColorSpace = {
#if os(watchOS)
	return GenericRGBAColorSpace
#else
	let rgba = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
	return rgba.colorSpace ?? CGColorSpace(name: GenericRGBAColorSpaceName)!
#endif
}()

/// The colorspace name for the default color
let CalculatedRGBColorSpaceName: CFString = {
	CalculatedRGBColorSpace.name ?? GenericRGBAColorSpaceName
}()

extension CGColor {
	// A common wrapper around creating a generic RGBA color across supported platforms
	static func Create(genericRed red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> CGColor {
#if os(watchOS)
		return CGColor(colorSpace: CalculatedRGBColorSpace, components: [red, green, blue, alpha])!
#else
		return CGColor(red: red, green: green, blue: blue, alpha: alpha)
#endif
	}
}
