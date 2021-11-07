//
//  DSFColorList+Image.swift
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
	/// Generate a CGImage of the list of colors. Useful for drag item images etc.
	/// - Parameters:
	///   - size: The point size of the resulting image
	///   - cornerRadius: The corner radius
	///   - scale: The scale to use when creating the image
	///   - colors: The list of colors to generate
	/// - Returns: The created CGImage, or nil if an error occurred
	func cgImage(size: CGSize, cornerRadius: CGFloat = 4, scale: CGFloat = 2) -> CGImage? {
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
		guard let bitmapContext = CGContext(
			data: nil,
			width: Int(size.width * scale),
			height: Int(size.height * scale),
			bitsPerComponent: 8,
			bytesPerRow: 0,
			space: colorSpace,
			bitmapInfo: bitmapInfo.rawValue
		) else {
			Swift.print("(ERROR) DSFSparklineBitmap unable to generate bitmap context for drawing")
			return nil
		}

		bitmapContext.saveGState()
		DSFColorList.DrawImage(in: bitmapContext, scale: scale, size: size, cornerRadius: cornerRadius, colors: colors)
		bitmapContext.restoreGState()

		return bitmapContext.makeImage()
	}
}

private extension DSFColorList {
	// The drawing routine for generating an image of an array of colors
	static func DrawImage(
		in ctx: CGContext,
		scale: CGFloat,
		size: CGSize,
		cornerRadius: CGFloat,
		colors: [DSFNamedColor]
	) {
		let newSize = CGSize(width: size.width * scale, height: size.height * scale)
		let newRect = CGRect(origin: .zero, size: newSize)

		let maskPath = CGPath(
			roundedRect: newRect.insetBy(dx: 0.5, dy: 0.5),
			cornerWidth: cornerRadius * scale,
			cornerHeight: cornerRadius * scale,
			transform: nil
		)
		ctx.addPath(maskPath)
		ctx.clip()

		let xdiv = (newSize.width / CGFloat(colors.count)).rounded(.towardZero)

		var template = CGRect(origin: .zero,
									 size: CGSize(width: xdiv, height: newSize.height))

		colors.enumerated().forEach { iter in
			ctx.setFillColor(iter.element.color)
			template.origin.x = (xdiv * CGFloat(iter.offset))
			if iter.offset == (colors.count - 1) {
				template.size.width = newRect.width - template.origin.x
			}

			ctx.fill(template)
		}

		ctx.resetClip()
	}
}

// MARK: - Generating images

public extension DSFColorList {

#if os(macOS)
	/// Generate an NSImage of the list of colors. Useful for drag item images etc.
	/// - Parameters:
	///   - size: The point size of the resulting image
	///   - cornerRadius: The corner radius
	///   - scale: The scale to use when creating the image
	/// - Returns: The created CGImage, or nil if an error occurred
	func image(size: CGSize, cornerRadius: CGFloat = 4, scale: CGFloat = 2) -> NSImage? {
		guard let image = self.cgImage(size: size, cornerRadius: cornerRadius, scale: scale) else {
			return nil
		}
		return NSImage(cgImage: image, size: size)
	}

#else
	/// Generate a UIImage of the list of colors. Useful for drag item images etc.
	/// - Parameters:
	///   - size: The point size of the resulting image
	///   - cornerRadius: The corner radius
	///   - scale: The scale to use when creating the image

	/// - Returns: The created CGImage, or nil if an error occurred
	func image(size: CGSize, cornerRadius: CGFloat = 4, scale: CGFloat = 2) -> UIImage? {
		guard let image = self.cgImage(size: size, cornerRadius: cornerRadius, scale: scale) else {
			return nil
		}
		return UIImage(cgImage: image, scale: scale, orientation: .up)
	}
#endif
}
