@testable import DSFColorList
import XCTest

#if os(macOS)
import AppKit
#else
import UIKit
#endif

final class DSFColorListTests: XCTestCase {
	private func performTest(closure: () throws -> Void) {
		do {
			try closure()
		}
		catch {
			XCTFail("Unexpected error thrown: \(error)")
		}
	}


	func testDocoContent() {
		self.performTest {
			let colorList = DSFColorList.RGBA(name: "Dreamful Space Palette")
			colorList.append(name: "#efd3bb", CGColor(red: 0.940, green: 0.828, blue: 0.734, alpha: 1.000))
			colorList.append(name: "#d7808c", CGColor(red: 0.846, green: 0.503, blue: 0.550, alpha: 1.000))
			colorList.append(name: "#873677", CGColor(red: 0.531, green: 0.214, blue: 0.470, alpha: 1.000))
			colorList.append(name: "#1f1939", CGColor(red: 0.123, green: 0.099, blue: 0.227, alpha: 1.000))

			// Encode to a common text format
			let jsonEncoded = try colorList.encodeJSON()

			// Decode from common text format
			let decoded = try DSFColorList.RGBA(jsonString: jsonEncoded)

			XCTAssertEqual(colorList.name, decoded.name)
			XCTAssertEqual(0.940, decoded[0].color.components![0], accuracy: 0.0001)
			XCTAssertEqual(0.828, decoded[0].color.components![1], accuracy: 0.0001)
			XCTAssertEqual(0.734, decoded[0].color.components![2], accuracy: 0.0001)
			XCTAssertEqual(1.000, decoded[0].color.components![3], accuracy: 0.0001)

			XCTAssertEqual(0.846, decoded[1].color.components![0], accuracy: 0.0001)
			XCTAssertEqual(0.503, decoded[1].color.components![1], accuracy: 0.0001)
			XCTAssertEqual(0.550, decoded[1].color.components![2], accuracy: 0.0001)
			XCTAssertEqual(1.000, decoded[1].color.components![3], accuracy: 0.0001)

			XCTAssertEqual(0.531, decoded[2].color.components![0], accuracy: 0.0001)
			XCTAssertEqual(0.214, decoded[2].color.components![1], accuracy: 0.0001)
			XCTAssertEqual(0.470, decoded[2].color.components![2], accuracy: 0.0001)
			XCTAssertEqual(1.000, decoded[2].color.components![3], accuracy: 0.0001)

			XCTAssertEqual(0.123, decoded[3].color.components![0], accuracy: 0.0001)
			XCTAssertEqual(0.099, decoded[3].color.components![1], accuracy: 0.0001)
			XCTAssertEqual(0.227, decoded[3].color.components![2], accuracy: 0.0001)
			XCTAssertEqual(1.000, decoded[3].color.components![3], accuracy: 0.0001)

			#if os(macOS)

			// Add to a pasteboard
			let pb = NSPasteboard(name: NSPasteboard.Name(rawValue: "testing"))
			pb.clearContents()
			try colorList.setOnPasteboard(pb)

			// Load from a pasteboard
			let pastedColorList = try DSFColorList.RGBA.Load(from: pb)

			XCTAssertEqual(colorList.name, pastedColorList.name)
			XCTAssertEqual(colorList.colors.count, pastedColorList.colors.count)

			#elseif os(iOS)

			// Add to a pasteboard
			let pb = UIPasteboard(name: UIPasteboard.Name(rawValue: "testing"), create: true)!
			try colorList.setOnPasteboard(pb)

			// Load from a pasteboard
			let pastedColorList = try DSFColorList.RGBA.Load(from: pb)

			XCTAssertEqual(colorList.name, pastedColorList.name)
			XCTAssertEqual(colorList.colors.count, pastedColorList.colors.count)

			#endif
		}
	}



#if os(macOS)

	func testSimpleMacOS_1() {
		self.performTest {
			let colorlist1 = DSFColorList.Colorspace(colors: [
				NSColor.systemBlue.cgColor,
				NSColor(deviceCyan: 1, magenta: 0, yellow: 0, black: 0, alpha: 1).cgColor,
				NSColor(white: 0.2, alpha: 0.3).cgColor,
				NSColor(srgbRed: 0.0, green: 0.3, blue: 0.6, alpha: 0.9).cgColor,
			])

			let encoded = try colorlist1.encodeJSON()

			// Code for printing the JSON encoding
			// Swift.print(encoded)

			let colorlist2 = try XCTUnwrap(DSFColorList.Colorspace(jsonString: encoded))

			XCTAssertEqual(colorlist1.count, colorlist2.count)
			XCTAssertEqual(colorlist1[0].colorSpaceName, colorlist2[0].colorSpaceName)
			XCTAssertEqual(colorlist1[1].colorSpaceName, colorlist2[1].colorSpaceName)
			XCTAssertEqual(colorlist1[2].colorSpaceName, colorlist2[2].colorSpaceName)
			XCTAssertEqual(colorlist1[3].colorSpaceName, colorlist2[3].colorSpaceName)
		}
	}

#endif

#if os(iOS)
	func testSimpleUIKit_1() {
		performTest {

			let colorlist1 = DSFColorList.Colorspace(colors: [
				UIColor.lightText.cgColor,
				UIColor(hue: 0.2, saturation: 0.4, brightness: 0.6, alpha: 0.8).cgColor,
				UIColor(displayP3Red: 1, green: 1, blue: 0, alpha: 1).cgColor,
			])

			let encoded = try XCTUnwrap(colorlist1.encodeJSON())

			// Code for printing the JSON encoding
			//Swift.print(cl1)

			let colorlist2 = try XCTUnwrap(try DSFColorList.Colorspace(jsonString: encoded))

			XCTAssertEqual(colorlist1.count, colorlist2.count)
			XCTAssertEqual(colorlist1[0].colorSpaceName, colorlist2[0].colorSpaceName)
			XCTAssertEqual(colorlist1[1].colorSpaceName, colorlist2[1].colorSpaceName)
			XCTAssertEqual(colorlist1[2].colorSpaceName, colorlist2[2].colorSpaceName)
		}
	}
#endif

	// Extracted from macOS encoding in testSimpleMacOS_1()
	let macosJSON = #"{"colors":[{"components":[0.039215686274509803,0.51764705882352946,1,1],"colorspaceName":"kCGColorSpaceSRGB"},{"components":[1,0,0,0,1],"colorspaceName":"kCGColorSpaceDeviceCMYK"},{"components":[0.20000000000000001,0.29999999999999999],"colorspaceName":"kCGColorSpaceGenericGrayGamma2_2"},{"components":[0,0.29999999999999999,0.59999999999999998,0.90000000000000002],"colorspaceName":"kCGColorSpaceSRGB"}]}"#
	let iosJSON = #"{"colors":[{"components":[1,0.59999999999999998],"colorspaceName":"kCGColorSpaceExtendedGray"},{"components":[0.55199999999999994,0.59999999999999998,0.35999999999999999,0.80000000000000004],"colorspaceName":"kCGColorSpaceExtendedSRGB"},{"components":[1.0000120401382446,0.99999052286148071,-0.34620207548141479,1],"colorspaceName":"kCGColorSpaceExtendedSRGB"}]}"#

	func testSimpleDecode() {
		self.performTest {

			let cl = try XCTUnwrap(try? DSFColorList.Colorspace(jsonString: macosJSON))
			XCTAssertEqual(cl.count, 4)
			XCTAssertEqual(cl[0].color.colorSpace?.name, "kCGColorSpaceSRGB" as CFString)
			XCTAssertEqual(cl[1].color.colorSpace?.name, "kCGColorSpaceDeviceCMYK" as CFString)
			XCTAssertEqual(cl[2].color.colorSpace?.name, "kCGColorSpaceGenericGrayGamma2_2" as CFString)
			XCTAssertEqual(cl[3].color.colorSpace?.name, "kCGColorSpaceSRGB" as CFString)

			let cl2 = try XCTUnwrap(try? DSFColorList.Colorspace(jsonString: iosJSON))
			XCTAssertEqual(cl2.count, 3)
			XCTAssertEqual(cl2[0].color.colorSpace?.name, "kCGColorSpaceExtendedGray" as CFString)
			XCTAssertEqual(cl2[1].color.colorSpace?.name, "kCGColorSpaceExtendedSRGB" as CFString)
			XCTAssertEqual(cl2[2].color.colorSpace?.name, "kCGColorSpaceExtendedSRGB" as CFString)
		}
	}

	// Test decoding DSFColorList from a json string
	func testSimpleJSONDecode() {
		self.performTest {
			XCTAssertThrowsError(try DSFColorList.Colorspace(jsonString: "asdf"))
		}
	}

	let b64macOSData = "eyJjb2xvcnMiOlt7ImNvbXBvbmVudHMiOlswLDAsMSwwLjIwMDAwMDAwMDAwMDAwMDAxXSwiY29sb3JzcGFjZU5hbWUiOiJrQ0dDb2xvclNwYWNlU1JHQiJ9LHsiY29tcG9uZW50cyI6WzEsMCwwLDAsMV0sImNvbG9yc3BhY2VOYW1lIjoia0NHQ29sb3JTcGFjZUdlbmVyaWNDTVlLIn0seyJjb21wb25lbnRzIjpbMC4yMDAwMDAwMDAwMDAwMDAwMSwwLjI5OTk5OTk5OTk5OTk5OTk5XSwiY29sb3JzcGFjZU5hbWUiOiJrQ0dDb2xvclNwYWNlR2VuZXJpY0dyYXkifSx7ImNvbXBvbmVudHMiOlswLDAuMjk5OTk5OTk5OTk5OTk5OTksMC41OTk5OTk5OTk5OTk5OTk5OCwwLjkwMDAwMDAwMDAwMDAwMDAyXSwiY29sb3JzcGFjZU5hbWUiOiJrQ0dDb2xvclNwYWNlU1JHQiJ9XX0="
	let b64iOSData = "eyJjb2xvcnMiOlt7ImNvbXBvbmVudHMiOlswLDAsMSwwLjIwMDAwMDAwMDAwMDAwMDAxXSwiY29sb3JzcGFjZU5hbWUiOiJrQ0dDb2xvclNwYWNlU1JHQiJ9LHsiY29tcG9uZW50cyI6WzEsMCwwLDAsMV0sImNvbG9yc3BhY2VOYW1lIjoia0NHQ29sb3JTcGFjZUdlbmVyaWNDTVlLIn0seyJjb21wb25lbnRzIjpbMC4yMDAwMDAwMDAwMDAwMDAwMSwwLjI5OTk5OTk5OTk5OTk5OTk5XSwiY29sb3JzcGFjZU5hbWUiOiJrQ0dDb2xvclNwYWNlR2VuZXJpY0dyYXkifSx7ImNvbXBvbmVudHMiOlswLDAuMjk5OTk5OTk5OTk5OTk5OTksMC41OTk5OTk5OTk5OTk5OTk5OCwwLjkwMDAwMDAwMDAwMDAwMDAyXSwiY29sb3JzcGFjZU5hbWUiOiJrQ0dDb2xvclNwYWNlU1JHQiJ9XX0="
	let b64WatchOSData = "eyJjb2xvcnMiOlt7ImNvbXBvbmVudHMiOlswLDAsMSwwLjIwMDAwMDAwMDAwMDAwMDAxXSwiY29sb3JzcGFjZU5hbWUiOiJrQ0dDb2xvclNwYWNlU1JHQiJ9LHsiY29tcG9uZW50cyI6WzEsMCwwLDAsMV0sImNvbG9yc3BhY2VOYW1lIjoia0NHQ29sb3JTcGFjZUdlbmVyaWNDTVlLIn0seyJjb21wb25lbnRzIjpbMC4yMDAwMDAwMDAwMDAwMDAwMSwwLjI5OTk5OTk5OTk5OTk5OTk5XSwiY29sb3JzcGFjZU5hbWUiOiJrQ0dDb2xvclNwYWNlR2VuZXJpY0dyYXkifSx7ImNvbXBvbmVudHMiOlswLDAuMjk5OTk5OTk5OTk5OTk5OTksMC41OTk5OTk5OTk5OTk5OTk5OCwwLjkwMDAwMDAwMDAwMDAwMDAyXSwiY29sb3JzcGFjZU5hbWUiOiJrQ0dDb2xvclNwYWNlU1JHQiJ9XX0="

	// Test decoding DSFColorList from a binary blob
	func testSimpleBinaryDecodeEncode() {
		self.performTest {

			// Encoding generator
//			let colorlist1 = DSFColorList.Colorspace(colors: [
//				CGColor(srgbRed: 0, green: 0, blue: 1, alpha: 0.2),
//				CGColor(genericCMYKCyan: 1, magenta: 0, yellow: 0, black: 0, alpha: 1),
//				CGColor(gray: 0.2, alpha: 0.3),
//				CGColor(srgbRed: 0.0, green: 0.3, blue: 0.6, alpha: 0.9),
//			])
//			let data = try colorlist1.encodeData()
//			let b64 = data.base64EncodedString()

			// Load binary data encoded on macOS
			guard let d = Data(base64Encoded: b64macOSData) else {
				XCTAssert(false)
				return
			}

			let cl = try XCTUnwrap(DSFColorList.Colorspace.Decode(data: d))
			XCTAssertEqual(cl.count, 4)
			XCTAssertEqual(cl[0].colorSpaceName, "kCGColorSpaceSRGB")
			XCTAssertEqual(cl[1].colorSpaceName, "kCGColorSpaceGenericCMYK")
			XCTAssertEqual(cl[2].colorSpaceName, "kCGColorSpaceGenericGray")
			XCTAssertEqual(cl[3].colorSpaceName, "kCGColorSpaceSRGB")

			// Load binary data encoded on iOS
			guard let d2 = Data(base64Encoded: b64iOSData) else {
				XCTAssert(false)
				return
			}

			let cl2 = try XCTUnwrap(DSFColorList.Colorspace.Decode(data: d2))
			XCTAssertEqual(cl2.count, 4)
			XCTAssertEqual(cl2[0].colorSpaceName, "kCGColorSpaceSRGB")
			XCTAssertEqual(cl2[1].colorSpaceName, "kCGColorSpaceGenericCMYK")
			XCTAssertEqual(cl2[2].colorSpaceName, "kCGColorSpaceGenericGray")
			XCTAssertEqual(cl2[3].colorSpaceName, "kCGColorSpaceSRGB")

			// Load binary data encoded on iOS
			guard let d3 = Data(base64Encoded: b64WatchOSData) else {
				XCTAssert(false)
				return
			}

			let cl3 = try XCTUnwrap(DSFColorList.Colorspace.Decode(data: d3))
			XCTAssertEqual(cl3.count, 4)
			XCTAssertEqual(cl3[0].colorSpaceName, "kCGColorSpaceSRGB")
			XCTAssertEqual(cl3[1].colorSpaceName, "kCGColorSpaceGenericCMYK")
			XCTAssertEqual(cl3[2].colorSpaceName, "kCGColorSpaceGenericGray")
			XCTAssertEqual(cl3[3].colorSpaceName, "kCGColorSpaceSRGB")
		}
	}

	func testImageCreation() {
		self.performTest {
			let cl1 = [
				CGColor(red: 1, green: 0, blue: 0, alpha: 1),
				CGColor(red: 0, green: 1, blue: 0, alpha: 1),
				CGColor(red: 0, green: 0, blue: 1, alpha: 1),
				CGColor(genericCMYKCyan: 1, magenta: 0, yellow: 0, black: 0, alpha: 0.5),
				CGColor(genericCMYKCyan: 0, magenta: 1, yellow: 0, black: 0, alpha: 0.5),
				CGColor(genericCMYKCyan: 0, magenta: 0, yellow: 1, black: 0, alpha: 0.5),
				CGColor(genericCMYKCyan: 0, magenta: 0, yellow: 0, black: 1, alpha: 0.5),
			]

			let l1 = DSFColorList.Colorspace(colors: cl1)

			let image = l1.image(size: CGSize(width: 100, height: 20), scale: 2)
			XCTAssertNotNil(image)
			XCTAssertEqual(image!.size.width, 100)
			XCTAssertEqual(image!.size.height, 20)

			let cgImage = l1.cgImage(size: CGSize(width: 100, height: 20), scale: 2)
			XCTAssertNotNil(cgImage)
			XCTAssertEqual(cgImage!.width, 200)
			XCTAssertEqual(cgImage!.height, 40)
		}
	}

	func testSimpleColorList() {
		self.performTest {
			let colors = [
				CGColor(red: 1, green: 0, blue: 0, alpha: 0.5),
				CGColor(red: 0, green: 1, blue: 0, alpha: 0.3),
				CGColor(red: 0, green: 0, blue: 1, alpha: 0.1),
				CGColor(genericCMYKCyan: 1, magenta: 0, yellow: 0, black: 0, alpha: 0.5),
				CGColor(genericCMYKCyan: 0, magenta: 1, yellow: 0, black: 0, alpha: 0.5),
				CGColor(genericCMYKCyan: 0, magenta: 0, yellow: 1, black: 0, alpha: 0.5),
				CGColor(genericCMYKCyan: 0, magenta: 0, yellow: 0, black: 1, alpha: 0.5),
			]

			let str = try XCTUnwrap(DSFColorList.RGBA(colors: colors).encodeJSON())
			//Swift.print(str)

			let recon = try XCTUnwrap(DSFColorList.RGBA(jsonString: str))

			XCTAssertEqual(7, recon.count)

			/// Standard generic colorspace
			XCTAssertEqual(4, recon[0].color.numberOfComponents)
			XCTAssertEqual(1.0, recon[0].color.components![0], accuracy: 0.001)
			XCTAssertEqual(0.0, recon[0].color.components![1], accuracy: 0.001)
			XCTAssertEqual(0.0, recon[0].color.components![2], accuracy: 0.001)
			XCTAssertEqual(0.5, recon[0].color.components![3], accuracy: 0.001)

			/// CMWK colorspace has been converted to genericRGB
			XCTAssertEqual(4, recon[3].color.numberOfComponents)
			XCTAssertEqual(0.0, recon[3].color.components![0], accuracy: 0.001)
			XCTAssertEqual(0.5728, recon[3].color.components![1], accuracy: 0.001)
			XCTAssertEqual(0.8208, recon[3].color.components![2], accuracy: 0.001)
			XCTAssertEqual(0.5, recon[3].color.components![3], accuracy: 0.001)

			let cls2 = [
				CGColor(red: 1, green: 0, blue: 0, alpha: 0.5),
				CGColor(red: 0, green: 1, blue: 0, alpha: 1),
				CGColor(red: 0, green: 0, blue: 1, alpha: 1),
				CGColor(genericCMYKCyan: 1, magenta: 0, yellow: 0, black: 0, alpha: 0.5),
				CGColor(genericCMYKCyan: 0, magenta: 1, yellow: 0, black: 0, alpha: 0.5),
				CGColor(genericCMYKCyan: 0, magenta: 0, yellow: 1, black: 0, alpha: 0.5),
				CGColor(genericCMYKCyan: 0, magenta: 0, yellow: 0, black: 1, alpha: 0.5),
			]

			let clsss2 = DSFColorList.Colorspace(colors: cls2)

			let im2 = try XCTUnwrap(clsss2.cgImage(size: CGSize(width: 100, height: 20), scale: 2))
			XCTAssertEqual(im2.width, 200)
			XCTAssertEqual(im2.height, 40)

			let im3 = try XCTUnwrap(clsss2.image(size: CGSize(width: 100, height: 20), scale: 2))
			XCTAssertEqual(im3.size.width, 100)
			XCTAssertEqual(im3.size.height, 20)
		}
	}

	func testRGBAColorListPasteboard() {
		self.performTest {
			let cls2 = [
				CGColor(red: 1, green: 0, blue: 0, alpha: 0.5),
				CGColor(red: 0, green: 1, blue: 0, alpha: 1),
				CGColor(red: 0, green: 0, blue: 1, alpha: 1),
				CGColor(genericCMYKCyan: 1, magenta: 0, yellow: 0, black: 0, alpha: 0.5),
				CGColor(genericCMYKCyan: 0, magenta: 1, yellow: 0, black: 0, alpha: 0.5),
				CGColor(genericCMYKCyan: 0, magenta: 0, yellow: 1, black: 0, alpha: 0.5),
				CGColor(genericCMYKCyan: 0, magenta: 0, yellow: 0, black: 1, alpha: 0.5),
			]

			let cls222 = DSFColorList.RGBA(colors: cls2)

#if os(macOS)
			let customPasteboard = NSPasteboard(name: NSPasteboard.Name("testing"))
			customPasteboard.declareTypes([DSFColorList.RGBA.PasteboardType()], owner: nil)

			XCTAssertNoThrow(try cls222.setOnPasteboard(customPasteboard))

			let cpc = try DSFColorList.RGBA.Load(from: customPasteboard)
			XCTAssertNotNil(cpc)

			// Try on the general pasteboard
			NSPasteboard.general.declareTypes([DSFColorList.RGBA.PasteboardType()], owner: nil)
			XCTAssertNotNil(try cls222.setOnPasteboard(NSPasteboard.general))

			let cpc2 = try XCTUnwrap(DSFColorList.RGBA.Load(from: NSPasteboard.general))
			XCTAssertEqual(cpc2.count, cls2.count)
#elseif os(iOS)
			let customPasteboard = UIPasteboard(name: UIPasteboard.Name("testing"), create: true)!

			// Write to pasteboard
			XCTAssertNoThrow(try cls222.setOnPasteboard(customPasteboard))

			// Load back in...
			let cpc = try XCTUnwrap(try? DSFColorList.RGBA.Load(from: customPasteboard))
			XCTAssertEqual(cpc.count, cls2.count)

			// Now, try on the general pasteboard (why?  Shouldn't be any different)
			XCTAssertNoThrow(try cls222.setOnPasteboard(UIPasteboard.general))

			let cpc2 = try XCTUnwrap(try? DSFColorList.RGBA.Load(from: UIPasteboard.general))
			XCTAssertEqual(cpc2.count, cls2.count)
#endif
		}
	}

	func testPasteboardTests() {
		self.performTest {

			let cls = DSFColorList.RGBA(colors: [
				CGColor(red: 1, green: 0, blue: 0, alpha: 1),
				CGColor(red: 0, green: 1, blue: 0, alpha: 1),
				CGColor(red: 0, green: 0, blue: 1, alpha: 1),
			])

#if os(macOS)
			let types = [DSFColorList.RGBA.PasteboardType(), DSFColorList.Colorspace.PasteboardType()]

			let customPasteboard = NSPasteboard(name: NSPasteboard.Name("testing"))
			customPasteboard.declareTypes(types, owner: nil)

			XCTAssertNoThrow(try cls.setOnPasteboard(customPasteboard))

			XCTAssertEqual(customPasteboard.availableType(from: types), DSFColorList.RGBA.PasteboardType())

			// Should not be a colorspace color on the pasteboard
			XCTAssertNil(try? DSFColorList.Colorspace.Load(from: customPasteboard))

			// Should have RGBA on the pasteboard
			let unloaded1 = try DSFColorList.RGBA.Load(from: customPasteboard)

			XCTAssertEqual(3, unloaded1.count)
			XCTAssertEqual(1.0, unloaded1[0].color.redComponent,   accuracy: 0.001)
			XCTAssertEqual(0.0, unloaded1[0].color.greenComponent, accuracy: 0.001)
			XCTAssertEqual(0.0, unloaded1[0].color.blueComponent,  accuracy: 0.001)
			XCTAssertEqual(1.0, unloaded1[0].color.alphaComponent, accuracy: 0.001)
#endif
		}
	}

	#if os(macOS)

	func testNSColorListExtensions() {
		self.performTest {
			let cls = DSFColorList.RGBA(colors: [
				CGColor(red: 1, green: 0, blue: 0, alpha: 1),
				CGColor(red: 0, green: 1, blue: 0, alpha: 1),
				CGColor(red: 0, green: 0, blue: 1, alpha: 1),
			])

			let customPasteboard = NSPasteboard(name: NSPasteboard.Name("testing"))
			let availableTypes = [NSColorListPasteboardType]
			customPasteboard.declareTypes(availableTypes, owner: nil)

			// Check that the clipboard is empty
			XCTAssertThrowsError(try NSColorList.Load(from: customPasteboard))

			// Add NSColorList to the clipboard
			XCTAssertNoThrow(try cls.asNSColorList().setOnPasteboard(customPasteboard))

			// Check that its available on the clipboard
			let pb = try XCTUnwrap(try NSColorList.Load(from: customPasteboard))

			// Check the counts match
			XCTAssertEqual(pb.allKeys.count, cls.count)
		}
	}

	#endif

	func testColorListCodableDecodable() {
		struct MyObject<ColorType: DSFColorListColorTransformer>: Codable {
			let title: String
			let colorList: DSFColorList.Transformer<ColorType>
		}

		self.performTest {
			let myObject = MyObject<DSFColorList.RGBATransformer>(
				title: "testing",
				colorList: DSFColorList.RGBA(name: "rgb", colors: [
					CGColor(red: 1, green: 0, blue: 0, alpha: 1),
					CGColor(red: 0, green: 1, blue: 0, alpha: 1),
					CGColor(red: 0, green: 0, blue: 1, alpha: 1),
				]))

			// encode
			let enc = try XCTUnwrap(try JSONEncoder().encode(myObject))
			// decode
			let newObj = try XCTUnwrap(try JSONDecoder().decode(MyObject<DSFColorList.RGBATransformer>.self, from: enc))
			XCTAssertEqual(myObject.title, newObj.title)
			XCTAssertEqual(myObject.colorList.name, newObj.colorList.name)
			XCTAssertEqual(myObject.colorList.count, newObj.colorList.count)
		}

		self.performTest {
			let myObject = MyObject<DSFColorList.ColorSpaceTransformer>(
				title: "testing",
				colorList: DSFColorList.Colorspace(name: "mixed", colors: [
					CGColor(red: 1, green: 0, blue: 0, alpha: 1),
					CGColor(red: 0, green: 1, blue: 0, alpha: 1),
					CGColor(red: 0, green: 0, blue: 1, alpha: 1),
					CGColor(genericCMYKCyan: 0, magenta: 0, yellow: 1, black: 0, alpha: 0.5),
				]))

			// encode
			let enc = try XCTUnwrap(try JSONEncoder().encode(myObject))
			// decode
			let newObj = try XCTUnwrap(try JSONDecoder().decode(MyObject<DSFColorList.ColorSpaceTransformer>.self, from: enc))
			XCTAssertEqual(myObject.title, newObj.title)
			XCTAssertEqual(myObject.colorList.name, newObj.colorList.name)
			XCTAssertEqual(myObject.colorList.count, newObj.colorList.count)
		}
	}

	func testNamedColor() {

		self.performTest {
			let r1 = DSFNamedColor(name: "Red", color: CGColor(red: 1, green: 0, blue: 0, alpha: 1))
			let g1 = DSFNamedColor(name: "Green", color: CGColor(red: 0, green: 1, blue: 0, alpha: 1))
			let b1 = DSFNamedColor(name: "Blue", color: CGColor(red: 0, green: 0, blue: 1, alpha: 1))
			let u1 = DSFNamedColor(name: nil, color: CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5))
			let c1 = DSFColorList.RGBA(name: "Mine", colors: [r1, g1, b1, u1])

			let ed1 = try JSONEncoder().encode(c1)
			//let es1 = String(data: ed1, encoding: .utf8)!
			//Swift.print(es1)

			let c2 = try JSONDecoder().decode(DSFColorList.RGBA.self, from: ed1)
			//Swift.print(c2)

			XCTAssertEqual(c1.name, c2.name)
			XCTAssertEqual(c1.colors.count, c2.colors.count)
			XCTAssertEqual(c1.colors[0].name, c2.colors[0].name)
			XCTAssertEqual(c1.colors[1].name, c2.colors[1].name)
			XCTAssertEqual(c1.colors[2].name, c2.colors[2].name)
			XCTAssertEqual(c1.colors[3].name, c2.colors[3].name)
		}

		self.performTest {
			let r1 = DSFNamedColor(name: "Red", color: CGColor(red: 1, green: 0, blue: 0, alpha: 1))
			let g1 = DSFNamedColor(name: "Green", color: CGColor(red: 0, green: 1, blue: 0, alpha: 1))
			let b1 = DSFNamedColor(name: "Blue", color: CGColor(red: 0, green: 0, blue: 1, alpha: 1))
			let u1 = DSFNamedColor(name: nil, color: CGColor(genericCMYKCyan: 0, magenta: 0, yellow: 1, black: 0, alpha: 0.5))
			let c1 = DSFColorList.Colorspace(name: "Mine", colors: [r1, g1, b1, u1])

			let ed1 = try JSONEncoder().encode(c1)
			//let es1 = String(data: ed1, encoding: .utf8)!
			//Swift.print(es1)

			let c2 = try JSONDecoder().decode(DSFColorList.Colorspace.self, from: ed1)
			//Swift.print(c2)

			XCTAssertEqual(c1.name, c2.name)
			XCTAssertEqual(c1.colors.count, c2.colors.count)
			XCTAssertEqual(c1.colors[0].name, c2.colors[0].name)
			XCTAssertEqual(c1.colors[1].name, c2.colors[1].name)
			XCTAssertEqual(c1.colors[2].name, c2.colors[2].name)
			XCTAssertEqual(c1.colors[3].name, c2.colors[3].name)
		}
	}


	func testEncodeDecodeNaming() {

		self.performTest {

			let colorList = DSFColorList.RGBA(name: "Dreamful Space Palette")
			colorList.append(name: "#efd3bb", CGColor(red: 0.940, green: 0.828, blue: 0.734, alpha: 1.000))
			colorList.append(name: "#d7808c", CGColor(red: 0.846, green: 0.503, blue: 0.550, alpha: 1.000))
			colorList.append(name: "#873677", CGColor(red: 0.531, green: 0.214, blue: 0.470, alpha: 1.000))
			colorList.append(name: "#1f1939", CGColor(red: 0.123, green: 0.099, blue: 0.227, alpha: 1.000))

			let encoded = try XCTUnwrap(try colorList.encodeJSON())
			XCTAssertGreaterThan(encoded.count, 0)
			//Swift.print(encoded)

			let colorlist2 = try DSFColorList.RGBA(jsonString: encoded)
			XCTAssertEqual(colorlist2.count, 4)
			XCTAssertEqual(colorlist2.name, "Dreamful Space Palette")
			XCTAssertEqual(colorlist2[0].name, "#efd3bb")
			XCTAssertEqual(colorlist2[1].name, "#d7808c")
			XCTAssertEqual(colorlist2[2].name, "#873677")
			XCTAssertEqual(colorlist2[3].name, "#1f1939")
		}
	}

	func testEncodeDecodeNaming2() {

		self.performTest {
			let colors1 = DSFColorList(
				name: "DREAMFUL SPACE PALETTE",
				colors: [
					DSFNamedColor(color: CGColor(red: 1, green: 0, blue: 0, alpha: 0.5)),
					DSFNamedColor(color: CGColor(red: 0, green: 1, blue: 0, alpha: 0.5)),
					DSFNamedColor(color: CGColor(red: 0, green: 0, blue: 1, alpha: 0.5)),
					DSFNamedColor(color: CGColor(genericCMYKCyan: 0, magenta: 0, yellow: 1, black: 0, alpha: 1)),
				])

			let rawDataRGBA = try XCTUnwrap(try? colors1.encode(DSFColorList.RGBATransformer.self))
			let jsonStringRGBA = try XCTUnwrap(try? colors1.encodeJSON(DSFColorList.RGBATransformer.self))
			XCTAssertGreaterThan(jsonStringRGBA.count, 0)
			//Swift.print(jsonStringRGBA)
			let colors11 = try XCTUnwrap(try DSFColorList.Decode(DSFColorList.RGBATransformer.self, data: rawDataRGBA))
			XCTAssertEqual(colors1.count, colors11.count)

			let jsonStringColorSpace = try XCTUnwrap(try? colors1.encodeJSON(DSFColorList.ColorSpaceTransformer.self))
			XCTAssertGreaterThan(jsonStringColorSpace.count, 0)
			//Swift.print(jsonStringColorSpace)
		}

		self.performTest {
			let colors1 = DSFColorList.RGBA(name: "Simple RGB", colors: [
				CGColor(red: 1, green: 0, blue: 0, alpha: 0.5),
				CGColor(red: 0, green: 1, blue: 0, alpha: 0.5),
				CGColor(red: 0, green: 0, blue: 1, alpha: 0.5),
				CGColor(genericCMYKCyan: 0, magenta: 0, yellow: 1, black: 0, alpha: 1),
			])
			let jsonString1 = try XCTUnwrap(try? colors1.encodeJSON())
			XCTAssertGreaterThan(jsonString1.count, 0)
			//Swift.print(jsonString1)

			let colors2 = DSFColorList.RGBA(colors: [
				CGColor(red: 1, green: 0, blue: 0, alpha: 0.5),
				CGColor(red: 0, green: 1, blue: 0, alpha: 0.5),
				CGColor(red: 0, green: 0, blue: 1, alpha: 0.5),
			])
			let jsonString2 = try XCTUnwrap(try? colors2.encodeJSON())
			XCTAssertGreaterThan(jsonString2.count, 0)
			//Swift.print(jsonString2)


			let colors3 = DSFColorList.Colorspace(name: "Colorspaced Colors", colors: [
				CGColor(red: 1, green: 0, blue: 0, alpha: 0.5),
				CGColor(red: 0, green: 1, blue: 0, alpha: 0.5),
				CGColor(red: 0, green: 0, blue: 1, alpha: 0.5),
				CGColor(genericCMYKCyan: 0, magenta: 0, yellow: 1, black: 0, alpha: 1),
			])
			let jsonString3 = try XCTUnwrap(try? colors3.encodeJSON())
			//Swift.print(jsonString3)


			let dec1 = try XCTUnwrap(try DSFColorList.Decode(jsonString: jsonString3))
			XCTAssertGreaterThan(dec1.count, 0)
			//Swift.print(dec1)
		}
	}


	func testGimpPalette() {
		self.performTest {
			let demo = """
				GIMP Palette
				#Palette Name: mona
				#Description:
				#Colors: 6
				91	64	78	5b404e
				119	90	95	775a5f
				142	116	112	8e7470
				172	155	144	ac9b90
				210	204	184	d2ccb8
				238	238	225	eeeee1
				"""

			let colorList = try XCTUnwrap(try GimpPalette.Decode(demo))
			XCTAssertEqual(colorList.name, nil)
			XCTAssertEqual(colorList.count, 6)

			let encoded = try XCTUnwrap(try GimpPalette.Encode(colorList))
			XCTAssertGreaterThan(encoded.count, 0)
		}

		self.performTest {
			let demo = """
				GIMP Palette
				Name:  Web design
				#
				105    210      231     Giant Goldfish
				167    219      219
				224    228      204
				243    134      48
				250    105      0
				255    255      255     separator
				233    76       111     Cardsox
				84     39       51
				90     106      98
				"""

			let colorList = try XCTUnwrap(try GimpPalette.Decode(demo))
			XCTAssertEqual(colorList.name, "Web design")
			XCTAssertEqual(colorList.count, 9)
			XCTAssertEqual(colorList[0].name, "Giant Goldfish")
			XCTAssertEqual(colorList[1].name, nil)
			XCTAssertEqual(colorList[6].name, "Cardsox")

			let encoded = try XCTUnwrap(try GimpPalette.Encode(colorList))
			XCTAssertGreaterThan(encoded.count, 0)
		}

		self.performTest {
			let demo = """
				GIMP Palette
				Name:インデックスカラー画像のパレット値を
				# https://techbase.kde.org/Projects/Usability/HIG/MockupToolkit
				252 252 252	Paper White
				239 240 241	Cardboard Grey
				189 195 199	bdc3c7
				149 165 166	95a5a6
				"""

			let colorList = try XCTUnwrap(try GimpPalette.Decode(demo))
			XCTAssertEqual(colorList.name, "インデックスカラー画像のパレット値を")
			XCTAssertEqual(colorList.count, 4)
			XCTAssertEqual(colorList[0].name, "Paper White")
			XCTAssertEqual(colorList[1].name, "Cardboard Grey")
			XCTAssertEqual(colorList[2].name, "bdc3c7")
			XCTAssertEqual(colorList[3].name, "95a5a6")
		}
	}

	func testRGBAPalette() {
		self.performTest {
			let demo = """
				#fcfc80
				#fcf87c
				#fcf478
				#f8f074
				#f8ec70
				#f4ec6c
				#ecdc5c
				"""

			let colorList = try XCTUnwrap(try RGBAPalette.Decode(demo))
			XCTAssertEqual(colorList.name, nil)
			XCTAssertEqual(colorList.count, 7)


			let encoded = try RGBAPalette.Encode(colorList, includeAlpha: false)
			XCTAssertGreaterThan(encoded.count, 0)
			XCTAssertEqual(encoded.trimmingCharacters(in: .whitespacesAndNewlines),
								demo.trimmingCharacters(in: .whitespacesAndNewlines))
		}
	}

}

extension CGColor {
	var redComponent:   CGFloat { return components![0] }
	var greenComponent: CGFloat { return components![1] }
	var blueComponent:  CGFloat { return components![2] }
	var alphaComponent: CGFloat { return components![3] }
}
