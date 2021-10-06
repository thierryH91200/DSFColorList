//
//  RBGBAPalette.swift
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
import CoreGraphics.CGColor

import DSFRegex

/// A simple RGB(A) plain text file importer
///
/// Format of the form
/// ```
/// #fcfc80
/// #fcfc80
/// #fcf87c
/// #fcf87c
/// #fcf478
/// #f8f478
/// ```
public class RGBAPalette {

	/// Encode the colorlist as a simple text list of hex encoded colors
	static func Encode(_ source: DSFColorList, includeAlpha: Bool = true) throws -> String {
		var result = ""
		for color in source.colors {
			let rgb = try DSFColorList.RGBATransformer(name: color.name, color.color)
			let rh = String(format:"%02x", Int(rgb.r * 255))
			let gh = String(format:"%02x", Int(rgb.g * 255))
			let bh = String(format:"%02x", Int(rgb.b * 255))
			let ah = String(format:"%02x", Int(rgb.a * 255))
			result += "#\(rh)\(gh)\(bh)\(includeAlpha ? ah : "")\n"
		}
		return result
	}

	/// Decode a colorlist from a simple #RRGGBBAA format file (1 entry per line)
	static func Decode(_ string: String) throws -> DSFColorList {

		let colorList = DSFColorList()

		let lines = string.split(separator: "\n")
		for line in lines {
			let hexLine: String = {
				let fline = line.trimmingCharacters(in: .whitespacesAndNewlines)
				if fline.hasPrefix("#") {
					return String(line.suffix(line.count - 1))
				}
				else {
					return String(fline)
				}
			}()

			let scanner = Scanner(string: String(hexLine))
			var hexVal: UInt64 = 0
			if scanner.scanHexInt64(&hexVal) == false {
				continue
			}

			var red: CGFloat = 0.0
			var green: CGFloat = 0.0
			var blue: CGFloat = 0.0
			var alpha: CGFloat = 1.0

			if hexLine.count == 3 {
				// RGB
				red = CGFloat((hexVal & 0xF00) >> 8 * 17) / 255.0
				green = CGFloat((hexVal & 0x0F0) >> 4 * 17) / 255.0
				blue = CGFloat(hexVal & 0x00F * 17) / 255.0
				alpha = 1
			}
			else if hexLine.count == 6 {
				// RGB
				red = CGFloat((hexVal & 0xFF0000) >> 16) / 255.0
				green = CGFloat((hexVal & 0x00FF00) >> 8) / 255.0
				blue = CGFloat(hexVal & 0x0000FF) / 255.0
			}
			else if hexLine.count == 8 {
				// RGBA
				red = CGFloat((hexVal & 0xFF000000) >> 16) / 255.0
				green = CGFloat((hexVal & 0x00FF0000) >> 8) / 255.0
				blue = CGFloat(hexVal & 0x0000FF00) / 255.0
				alpha = CGFloat(hexVal & 0x000000FF) / 255.0
			}
			else {
				continue
			}

			colorList.append(CGColor.Create(genericRed: red, green: green, blue: blue, alpha: alpha))
		}

		return colorList
	}
}
