# DSFColorList

A cross-platform encodable color list container

<p align="center">
    <img src="https://img.shields.io/github/v/tag/dagronf/DSFColorList" />
    <img src="https://img.shields.io/badge/macOS-10.13+-red" />
    <img src="https://img.shields.io/badge/iOS-13+-blue" />
    <img src="https://img.shields.io/badge/tvOS-13+-orange" />
    <img src="https://img.shields.io/badge/watchOS-3+-yellow" />
</p>
<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.1-orange.svg" />
    <img src="https://img.shields.io/badge/SwifUI-2-ff69b4.svg" />
    <img src="https://img.shields.io/badge/License-MIT-lightgrey" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
</p>

Dependent on [DSFRegex](https://github.com/dagronf/DSFRegex) (for Gimp Palette parsing support)

## Why

Written for transferring colors between a Catalyst project on macOS and an AppKit app via the clipboard/drag-drop.

## Features

* A very simple, easy to parse, easy to read/write json format.
* Optional naming of individual colors
* Optional naming of the colorlist itself
* Cross-platform on Apple's platforms. You can encode on macOS and decode on iOS/watchOS (for example)
* Color ordering is maintained across encodings
* ColorSpace information is maintained (if using the ColorSpace encoder)
* Encode/Decode to/from a utf8-based JSON string (human readable)
* Encode/Decode to/from a binary blob (eg. for storing in core data)
* SwiftUI color support for macOS 12 and above, iOS 15 and above

## TL;DR - Show me something!

1. Create a named colorlist
2. Add some named colors
3. Add to pasteboard

```swift
let colorList = DSFColorList.RGBA(name: "Dreamful Space Palette")
colorList.append(name: "#efd3bb", CGColor(red: 0.940, green: 0.828, blue: 0.734, alpha: 1.000))
colorList.append(name: "#d7808c", CGColor(red: 0.846, green: 0.503, blue: 0.550, alpha: 1.000))
colorList.append(name: "#873677", CGColor(red: 0.531, green: 0.214, blue: 0.470, alpha: 1.000))
colorList.append(name: "#1f1939", CGColor(red: 0.123, green: 0.099, blue: 0.227, alpha: 1.000))

// Encode to a common text format
let jsonEncoded = try colorList.encodeJSON()

// Decode from common text format
let colorList = try DSFColorList.RGBA(jsonString: jsonEncoded)

// Add to a pasteboard
try colorList.setOnPasteboard(NSPasteboard.general)

// Load from a pasteboard
let pastedColorList = try DSFColorList.RGBA.Load(from: NSPasteboard.general)
```

## Transformers

A transformer converts a CGColor to/from an encodable struct. 

Currently, only colors with colorspaces that are componentized are supported. If a non-palettized color is found, it 
will attempt to convert to a supported colorspace first before throwing an error.

The built-in transformers are :-

* `DSFColorList.RGBA` : A simple RGBA transformer with optional color and colorlist names. 
* `DSFColorList.Colorspace` : An transformer that additionally encodes the Core Graphics colorspace name for each color 

## JSON Encoding Formats

### DSFColorList.RGBA

**UTI**: `public.dagronf.colorlist.rgba.json.utf8`

**ConformsTo**: `public.json`

`DSFColorList.RGBA` is an RGBA based encoder/decoder. Colors are converted to the default RGBA colorspace before encoding.

The benefit of this encoder is that the encode format is simple json and can be used to share color information
across different platforms.

```
{
   "name": String?,              // The optional name for the colorlist
   "colors": [                   // The array of colors within the colorlist
   {
      "name": String?            // The optional name for the color
      "r": Float                 // The red component for the color (0 -> 1)
      "g": Float                 // The green component for the color (0 -> 1)
      "b": Float                 // The blue component for the color (0 -> 1)
      "a": Float                 // The alpha component for the color (0 -> 1)
   }
]
```

They can be identified on the pasteboard with the pasteboard identifier `public.dagronf.colorlist.rgba.json.utf8`

<details>
  <summary>Example</summary>
  
### Named colorlist example

```swift
let colors = DSFColorList.RGBA(name: "Simple RGB", [
   CGColor(red: 1, green: 0, blue: 0, alpha: 0.5),
   CGColor(red: 0, green: 1, blue: 0, alpha: 0.5),
   CGColor(red: 0, green: 0, blue: 1, alpha: 0.5),
   CGColor(genericCMYKCyan: 0, magenta: 0, yellow: 1, black: 0, alpha: 1),
])

let jsonString = try colors.encodeJSON()
```

```json
{
  "name": "Simple RGB",
  "colors": [
    {
      "r": 1,
      "b": 0,
      "g": 0,
      "a": 0.5
    },
    {
      "r": 0,
      "b": 0,
      "g": 1,
      "a": 0.5
    },
    {
      "r": 0,
      "b": 1,
      "g": 0,
      "a": 0.5
    },
    {
      "r": 1,
      "b": 0.04351634532213211,
      "g": 0.9451282620429993,
      "a": 1
    }
  ]
}
```

### Unnamed colorlist example

```swift
let colors2 = DSFColorList.RGBA([
   CGColor(red: 1, green: 0, blue: 0, alpha: 0.5),
   CGColor(red: 0, green: 1, blue: 0, alpha: 0.5),
   CGColor(red: 0, green: 0, blue: 1, alpha: 0.5),
])
let jsonString2 = try colors2.encodeJSON()
```

```
{
  "colors": [
    {
      "r": 1,
      "b": 0,
      "g": 0,
      "a": 0.5
    },
    {
      "r": 0,
      "b": 0,
      "g": 1,
      "a": 0.5
    },
    {
      "r": 0,
      "b": 1,
      "g": 0,
      "a": 0.5
    }
  ]
}
```


</details>

### DSFColorList.Colorspace

**UTI**: `public.dagronf.colorlist.colorspace.json.utf8`

**ConformsTo**: `public.json`

`DSFColorList.Colorspace` is a more complex encoder that handles encoding of colors while attempting tp maintain the 
colorspace. The colorspace names are stored using their CoreGraphics name, so this format is compatible mostly
with OSes that support CoreGraphics.

In the case that a color cannot be converted or loaded for the specified colorlist, you can (optionally) provide a block
which will be called in the case of failure to allow you to convert the color yourself (`ColorSpaceFactoryCallback`).

They can be identified on the pasteboard with the pasteboard identifier `public.dagronf.colorlist.colorspace.json.utf8`

```
{
  "name": String?                   // The optional name for the colorlist
  "colors": [                       // The array of colors within the colorlist
    {
      "name": String?               // The optional name for the color
      "components": [ Float ],      // The component values for the color in the specified namespace
      "colorspaceName": String      // The Core Graphics name for the color's colorspace
    },
  ]
}
```

<details>
  <summary>Example</summary>
  
### Named Colorlist Example

```swift
let colors3 = DSFColorList.Colorspace(name: "Colorspaced Colors",[
   CGColor(red: 1, green: 0, blue: 0, alpha: 0.5),
   CGColor(red: 0, green: 1, blue: 0, alpha: 0.5),
   CGColor(red: 0, green: 0, blue: 1, alpha: 0.5),
   CGColor(genericCMYKCyan: 0, magenta: 0, yellow: 1, black: 0, alpha: 1),
])
let jsonString = try colors3.encodeJSON()
```

```json
{
  "name": "Colorspaced Colors",
  "colors": [
    {
      "components": [
        1,
        0,
        0,
        0.5
      ],
      "colorspaceName": "kCGColorSpaceGenericRGB"
    },
    {
      "components": [
        0,
        1,
        0,
        0.5
      ],
      "colorspaceName": "kCGColorSpaceGenericRGB"
    },
    {
      "components": [
        0,
        0,
        1,
        0.5
      ],
      "colorspaceName": "kCGColorSpaceGenericRGB"
    },
    {
      "components": [
        0,
        0,
        1,
        0,
        1
      ],
      "colorspaceName": "kCGColorSpaceGenericCMYK"
    }
  ]
}
```

### Unamed Colorlist Example

```swift
let colors4 = DSFColorList.Colorspace([
   CGColor(red: 1, green: 0, blue: 0, alpha: 0.5),
   CGColor(red: 0, green: 1, blue: 0, alpha: 0.5),
   CGColor(red: 0, green: 0, blue: 1, alpha: 0.5),
   CGColor(genericCMYKCyan: 0, magenta: 0, yellow: 1, black: 0, alpha: 1),
])
let jsonString = try colors4.encodeJSON()
```

```json
{
  "colors": [
    {
      "components": [
        1,
        0,
        0,
        0.5
      ],
      "colorspaceName": "kCGColorSpaceGenericRGB"
    },
    {
      "components": [
        0,
        1,
        0,
        0.5
      ],
      "colorspaceName": "kCGColorSpaceGenericRGB"
    },
    {
      "components": [
        0,
        0,
        1,
        0.5
      ],
      "colorspaceName": "kCGColorSpaceGenericRGB"
    },
    {
      "components": [
        0,
        0,
        1,
        0,
        1
      ],
      "colorspaceName": "kCGColorSpaceGenericCMYK"
    }
  ]
}
```
</details>

## Pasteboard support

`DSFColorList` includes helpers for encoding to and decoding from an NSPasteboard/UIPasteboard for macOS/iOS

```swift
let colorList = DSFColorList.RGBA(colors: [
   CGColor(red: 1, green: 0, blue: 0, alpha: 0.5),
   CGColor(red: 0, green: 1, blue: 0, alpha: 1),
   CGColor(red: 0, green: 0, blue: 1, alpha: 1),
])
try colorList.setOnPasteboard(NSPasteboard.general)
```

## NSColorList

`DSFColorList` provides convenience methods for converting to/from the macOS NSColorList format

## Custom encoders

This library contains two palette based custom encoder/decoder

* `GimpPalette` - An importer/exporter for gimp-format .gpl color palettes
* `RGBAPalette` - An importer/exporter for flat hex-encoded text color palettes

## Changes

### `0.5.0`

* Initial

# License

MIT. Use it for anything you want! Let me know if you do use it somewhere, I'd love to hear about it.

```
MIT License

Copyright (c) 2021 Darren Ford

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
