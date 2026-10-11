#!/usr/bin/env swift
//
// make-icon.swift — resize RADIO.png into every standard macOS icon size.
// The Makefile packages these PNGs with iconutil. Keep the supplied artwork
// intact: no extra tile, padding, cropping, or glyphs.

import AppKit
import ImageIO

let sourceURL = URL(fileURLWithPath: "RADIO.png")
let iconsetURL = URL(fileURLWithPath: "build/AppIcon.iconset", isDirectory: true)

func iconError(_ message: String) -> NSError {
    NSError(domain: "Radiology.AppIcon", code: 1,
            userInfo: [NSLocalizedDescriptionKey: message])
}

guard let source = CGImageSourceCreateWithURL(sourceURL as CFURL, nil),
      let artwork = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
    throw iconError("Could not load RADIO.png")
}
guard artwork.width == artwork.height else {
    throw iconError("RADIO.png must be square")
}

try FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

// (filename, pixel dimension) — the complete set iconutil expects.
let variants: [(String, Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024),
]

for (name, pixels) in variants {
    guard let context = CGContext(
        data: nil, width: pixels, height: pixels, bitsPerComponent: 8, bytesPerRow: 0,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
        throw iconError("Could not create the bitmap for \(name)")
    }
    context.interpolationQuality = .high
    let dimension = CGFloat(pixels)
    context.draw(artwork, in: CGRect(x: 0, y: 0, width: dimension, height: dimension))
    guard let image = context.makeImage(),
          let png = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:]) else {
        throw iconError("Could not encode \(name)")
    }
    try png.write(to: iconsetURL.appendingPathComponent(name), options: .atomic)
}

print("✓ wrote \(variants.count) icons from RADIO.png to \(iconsetURL.path)")
