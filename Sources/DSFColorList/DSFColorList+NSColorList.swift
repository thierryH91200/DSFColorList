//
//  DSFColorList+NSColorList.swift
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

// NSColorList support (macOS only)

#if os(macOS)
import AppKit
import CoreGraphics

// Internally defined types for NSColorList on the clipboard.
// Apple doesnt (seem to) provide a PasteboardType for NSColorList, so we'll just create one that _looks_ obvious to
// anyone observing the pasteboard

/// The pasteboard name to use when saving/loading an NSColorList from the clipboard
public let NSColorListPasteboardTypeName = "NSColorList.bplist"
/// The pasteboard type to use when saving/loading an NSColorList from the clipboard
public let NSColorListPasteboardType = NSPasteboard.PasteboardType(NSColorListPasteboardTypeName)

/// Helpers for converting between  NSColorList and DSFColorLists
public extension DSFColorList {
	/// Create a colorlist from an NSColorList
	convenience init(_ colorlist: NSColorList) throws {
		self.init(name: colorlist.name, colors: colorlist.namedColors())
	}

	/// Returns this colorlist as an NSColorList
	///
	/// May not return the same number of colors IF there are colors that cannot be converted to NSColor
	func asNSColorList() -> NSColorList {
		let colorlist = NSColorList()
		self.colors
			.map { $0.color }
			.compactMap { NSColor(cgColor: $0) }
			.enumerated()
			.forEach {
				// Use a name that makes it orderable
				let orderName = String(format: "%08d", $0.0)
				colorlist.setColor($0.1, forKey: orderName)
			}
		return colorlist
	}
}

// MARK: - NSColorList

public extension NSColorList {
	/// Create an NSColorList from an array of CGColor
	convenience init(colors: [CGColor]) throws {
		self.init()
		colors.compactMap { NSColor(cgColor: $0) }
		.enumerated()
		.forEach {
			// Use a name that makes it orderable
			let orderName = String(format: "%08d", $0.0)
			self.setColor($0.1, forKey: orderName)
		}
	}
	
	/// Extract the colors from the colorlist as an array of CGColor objects
	///
	/// Orders using the NSColorList keys
	func cgColors() -> [CGColor] {
		return self
			.allKeys.sorted()
			.compactMap { self.value(forKey: $0) as? NSColor }
			.compactMap { $0.cgColor }
	}

	/// Convert the NSColorList to a DSFColorList
	func colorList() -> DSFColorList {
		DSFColorList(name: self.name,
						 colors: self.namedColors())
	}

	/// Extract the colors in the NSColorlist into an array of NamedColors
	func namedColors() -> [DSFNamedColor] {
		return self
			.allKeys.sorted()
			.map { (name: $0, color: (self.value(forKey: $0) as? NSColor)?.cgColor) }
			.compactMap {
				if let c = $0.color {
					return DSFNamedColor(name: $0.name, color: c)
				}
				return nil
			}
	}
}

// MARK: - NSColorList encoding/decoding

public extension NSColorList {
	/// Encode the NSColorList as binary data, using a NSKeyedArchiver format (bplist)
	func encode() throws -> Data {
		if let data = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true) {
			return data
		}
		throw DSFColorList.ColorError.UnableToEncodeData
	}

	/// Extract a colorlist from NSKeyedArchiver-encoded data
	static func Decode(from data: Data) throws -> NSColorList {
		if let cl = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSColorList.self, from: data) {
			return cl
		}
		throw DSFColorList.ColorError.PasteboardDoesntContainColorlist
	}
}

// MARK: - NSColorList pasteboard helpers

public extension NSColorList {
	/// Set this colorlist onto the specified pasteboard using the pasteboard type 'NSColorListPasteboardType'
	func setOnPasteboard(_ pasteboard: NSPasteboard) throws {
		let data = try self.encode()
		pasteboard.setData(data, forType: NSColorListPasteboardType)
	}

	/// Attempt to load an NSColorList from the pasteboard, using the pasteboard type 'NSColorListPasteboardType'
	static func Load(from pasteboard: NSPasteboard) throws -> NSColorList {
		if let data = pasteboard.data(forType: NSColorListPasteboardType) {
			return try NSColorList.Decode(from: data)
		}
		throw DSFColorList.ColorError.PasteboardDoesntContainColorlist
	}
}

#endif
