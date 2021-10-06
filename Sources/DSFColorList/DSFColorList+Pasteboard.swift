//
//  DSFColorList+Pasteboard.swift
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

// Pasteboard related functions

import CoreGraphics
import Foundation

// MARK: - Pasteboard

#if os(macOS)

import AppKit

public extension DSFColorList {
	/// Put all the currently known colorlist formats onto the specified pasteboard
	func setAllOnPasteboard(pasteboard: NSPasteboard) throws {
		try? DSFColorList.RGBA(name: self.name, colors: self.colors).setOnPasteboard(pasteboard)
		try? DSFColorList.Colorspace(name: self.name, colors: self.colors).setOnPasteboard(pasteboard)
		try? NSColorList(colors: self.colors.map { $0.color }).setOnPasteboard(pasteboard)
	}

	/// Attempt to load a colorlist from any of the known pasteboard formats.
	static func LoadAny(from pasteboard: NSPasteboard) -> DSFColorList? {
		if let d = try? DSFColorList.Colorspace.Load(from: pasteboard) {
			return d
		}
		if let d = try? DSFColorList.RGBA.Load(from: pasteboard) {
			return d
		}
		if let d = try? NSColorList.Load(from: pasteboard) {
			return d.colorList()
		}
		return nil
	}
}

public extension DSFColorList.Transformer {
	/// Returns the PasteboardType for the colorlist as a String
	@inlinable static func PasteboardTypeName() -> String { CodableColorType.PasteboardTypeName() }
	/// Returns the PasteboardType for the colorlist as a PasteboardType
	@inlinable static func PasteboardType() -> NSPasteboard.PasteboardType {
		NSPasteboard.PasteboardType(CodableColorType.PasteboardTypeName())
	}

	/// Returns all the pasteboard types available for the platform
	static func AllPasteboardTypes() -> [String] {
		return [
			DSFColorList.RGBATransformer.PasteboardTypeName(),
			DSFColorList.ColorSpaceTransformer.PasteboardTypeName(),
			NSColorListPasteboardTypeName,
		]
	}

	/// Put the content of the colorlist onto the pasteboard using the color coder
	func setOnPasteboard(_ pasteboard: NSPasteboard) throws {
		let s = try self.encodeJSON()
		pasteboard.setString(s, forType: NSPasteboard.PasteboardType(CodableColorType.PasteboardTypeName()))
	}

	/// Attempt to load a colorlist from the pasteboard
	static func Load(from pasteboard: NSPasteboard) throws -> Self {
		if let strVal = pasteboard.string(forType: NSPasteboard.PasteboardType(CodableColorType.PasteboardTypeName())) {
			return try Self(jsonString: strVal)
		}
		throw DSFColorList.ColorError.PasteboardDoesntContainColorlist
	}
}

#elseif os(iOS)

import UIKit

public extension DSFColorList {
	/// Put all the currently known colorlist formats onto the specified pasteboard
	func setAllOnPasteboard(pasteboard: UIPasteboard) throws {
		try? DSFColorList.RGBA(name: self.name, colors: self.colors).setOnPasteboard(pasteboard)
		try? DSFColorList.Colorspace(name: self.name, colors: self.colors).setOnPasteboard(pasteboard)
	}

	/// Attempt to load a colorlist from any of the known pasteboard formats.
	static func LoadAny(from pasteboard: UIPasteboard) -> DSFColorList? {
		if let d = try? DSFColorList.Colorspace.Load(from: pasteboard) {
			return d
		}
		if let d = try? DSFColorList.RGBA.Load(from: pasteboard) {
			return d
		}
		return nil
	}
}

public extension DSFColorList.Transformer {
	/// Returns the PasteboardType for the colorlist as a String
	@inlinable static func PasteboardTypeName() -> String { CodableColorType.PasteboardTypeName() }

	/// Returns all the pasteboard types available for the platform
	static func AllPasteboardTypes() -> [String] {
		return [
			DSFColorList.RGBATransformer.PasteboardTypeName(),
			DSFColorList.ColorSpaceTransformer.PasteboardTypeName(),
		]
	}

	/// Add the specified array of colors to the provided pasteboard. Uses JSON format
	/// - Parameters:
	///   - colors: The colors to represent on the pasteboard
	///   - pasteboard: The pasteboard to add the colors to
	/// - Returns: true if the colors were able to be added, false otherwise
	///
	/// When setting on the built-in pasteboards make sure to declare the types beforehand on the pasteboard
	///   `pasteboard.declareTypes([NSPasteboard.RGBAColorListType], owner: nil)`, or
	///   `pasteboard.addTypes([NSPasteboard.RGBAColorListType], owner: nil)`
	func setOnPasteboard(_ pasteboard: UIPasteboard) throws {
		let s = try self.encodeJSON()
		pasteboard.setValue(s, forPasteboardType: CodableColorType.PasteboardTypeName())
	}

	/// Extract a colorlist of colors from the specified pasteboard. If there's no colorlist on the pasteboard returns nil
	/// - Parameter pasteboard: The pasteboard to retrieve colors from
	/// - Returns: The array of colors stored on 'pasteboard', else nil
	static func Load(from pasteboard: UIPasteboard) throws -> Self {
		if pasteboard.contains(pasteboardTypes: [CodableColorType.PasteboardTypeName()]),
			let data = pasteboard.value(forPasteboardType: CodableColorType.PasteboardTypeName()) as? Data,
			let strVal = String(data: data, encoding: .utf8)
		{
			return try Self(jsonString: strVal)
		}
		throw DSFColorList.ColorError.PasteboardDoesntContainColorlist
	}
}

#endif
