//
//  main.swift
//  PaletteExtractor
//
//  Created by Zoltán Majoros on 13/Apr/2015.
//  Copyright © 2017 Zoltán Majoros. All rights reserved.
//

import Foundation
import ImageIO

extension RGBColor: Equatable, Hashable
{
    public static func ==(lhs: RGBColor, rhs: RGBColor) -> Bool
    {
        return rhs.red == lhs.red && rhs.green == lhs.green && rhs.blue == lhs.blue
    }
    
    public var hashValue: Int
    {
        let r: uint32 = uint32(red) << 16
        let g: uint32 = uint32(green) << 8
        let b: uint32 = uint32(blue)
        
        return Int(uint32(r | g | b));
    }
}

// Entry point here //

if CommandLine.argc != 2
{
    print("usage: \(CommandLine.arguments[0]) ImageFileName")
    exit(0)
}

let filePath = CommandLine.arguments[1]
let fileManager = FileManager.default

let url = URL(fileURLWithPath: filePath)

guard let imageSource = CGImageSourceCreateWithURL(url as CFURL!, nil) else
{
    print("Error while loading image")
    exit(1)
}

guard let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else
{
    print("Error while loading image")
    exit(1)
}

print("Image dimensions: \(image.width)x\(image.height)\n")
//print("\(image.bitsPerPixel) bits per pixel")

let pixelPointer: UnsafePointer<uint8> = CFDataGetBytePtr(image.dataProvider?.data)

var colors = Array<RGBColor>()
var colorsWithLocation = Dictionary<RGBColor, Array<CGPoint>>()

guard image.width > 0 && image.height > 0 else { exit(0) }

for y in 0..<image.height
{
    let offsetY = 4*y
    for x in 0..<image.width
    {
        let offsetX = 4*x
        let r = pixelPointer[offsetY*image.width + offsetX]
        let g = pixelPointer[offsetY*image.width + offsetX+1]
        let b = pixelPointer[offsetY*image.width + offsetX+2]
//        let a = pixelPointer[offsetY*image.width + offsetX+3]
        let currentColor = RGBColor(red: UInt16(r), green: UInt16(g), blue: UInt16(b))
        if colors.contains(where: { $0 == currentColor }) { continue }
        colors.append(currentColor)
    }
}

//print("The image has \(colors.count) different colors.")
var i = 0;
for color in colors
{
    let hexColor = String(format: "#%06X", color.hashValue)
    print("palette[\(i)] = \(hexColor) (\(color.red),\(color.green),\(color.blue))");
    i = i+1
}
