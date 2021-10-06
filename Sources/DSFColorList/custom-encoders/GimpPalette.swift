//
//  GimpPalette.swift
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

/// A encoder/decoder for the GIMP palette format
///
/// Format of the form
/// ```
/// GIMP Palette
/// Name:  Web design
/// #
/// 105    210      231     Giant Goldfish
/// 167    219      219
/// 224    228      204
/// 243    134      48
/// 250    105      0
/// 255    255      255     separator
/// 233    76       111     Cardsox
/// 84     39       51
/// 90     106      98
/// ```
public class GimpPalette {
	/// Encode a colorlist to a GIMP palette format
	static func Encode(_ source: DSFColorList) throws -> String {

		var output = "GIMP Palette\n"
		if let name = source.name {
			output += "Name: \(name)\n"
		}

		output += "#Colors: \(source.count)\n"
		for color in source.colors {
			let rgb = try DSFColorList.RGBATransformer(name: color.name, color.color)

			let rv = Int(min(255, max(0, rgb.r * 255)).rounded(.towardZero))
			let gv = Int(min(255, max(0, rgb.g * 255)).rounded(.towardZero))
			let bv = Int(min(255, max(0, rgb.b * 255)).rounded(.towardZero))

			output += "\(rv)\t\(gv)\t\(bv)"
			if let name = rgb.name {
				output += "\t\(name)"
			}
			output += "\n"
		}
		return output
	}

	/// Decode a colorlist from a GIMP-format palette file (.gpl)
	static func Decode(_ string: String) throws -> DSFColorList {

		let lines = string.split(separator: "\n")
		guard lines.count > 0,
				lines[0] == "GIMP Palette" else {
			throw DSFColorList.ColorError.UnableToEncodeData
		}

		let colorList = DSFColorList()

		let regex = try DSFRegex(#"^(\d+)\s+(\d+)\s+(\d+)(.*)$"#)

		for line in lines.dropFirst() {
			if line.starts(with: "Name:") {
				//Name:  Web design
				let colorlistName = line.suffix(line.count - 5).trimmingCharacters(in: .whitespacesAndNewlines)
				if colorlistName.count > 0 {
					colorList.name = colorlistName
				}
			}
			else if line.starts(with: "#") {
				continue
			}

			let lineStr = String(line)

			let searchResult = regex.matches(for: lineStr)

			for match in searchResult {
				let rs = lineStr[match.captures[0]]
				let gs = lineStr[match.captures[1]]
				let bs = lineStr[match.captures[2]]
				let ss = lineStr[match.captures[3]]

				guard
					let rv = Int(rs),
					let gv = Int(gs),
					let bv = Int(bs)
				else {
					continue
				}
				
				let sv = ss.trimmingCharacters(in: .whitespacesAndNewlines)
				colorList.append(
					name: sv.count == 0 ? nil : sv,
					CGColor.Create(
						genericRed: max(0, min(1, CGFloat(rv)/255.0)),
						green: max(0, min(1, CGFloat(gv)/255.0)),
						blue: max(0, min(1, CGFloat(bv)/255.0)),
						alpha: 1))
			}
		}
		return colorList
	}
}
