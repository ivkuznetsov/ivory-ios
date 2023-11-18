//
//  UIImage+GIF.swift
//  Ivory
//
//  Created by Ilya Kuznetsov on 22/01/2023.
//

import UIKit

extension UIImage {

    public static func gifImage(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("image doesn't exist")
            return nil
        }

        return UIImage.animatedImage(with: source)
    }

    public static func gifImage(with url: String) -> UIImage? {
        guard let bundleURL = URL(string: url) else {
                print(#"image named "\#(url)" doesn't exist"#)
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print(#"image named "\#(url)\" into Data"#)
            return nil
        }

        return gifImage(data: imageData)
    }

    public static func gifImage(name: String) -> UIImage? {
        guard let bundleURL = Bundle.main.url(forResource: name, withExtension: "gif") else {
                print(#"This image named "\#(name)" does not exist"#)
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print(#"Cannot turn image named "\#(name)" into Data"#)
            return nil
        }
        return gifImage(data: imageData)
    }

    // MARK: - Private
    private static func delay(forImageAtIndex index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1

        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)

        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }

        delay = delayObject as! Double

        if delay < 0.1 {
            delay = 0.1
        }

        return delay
    }

    private static func gcdForPair(_ a: Int, _ b: Int) -> Int {
        var a = a, b = b
        if a < b { swap(&a, &b) }
        while true {
            guard a % b > 0 else { return b }
            a = b
            b = a % b
        }
    }

    private static func gcdForArray(_ array: [Int]) -> Int {
        guard var gcd = array.first else { return 1 }
        array.forEach { gcd = UIImage.gcdForPair($0, gcd) }
        return gcd
    }

    private static func animatedImage(with source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()

        (0..<count).forEach {
            if let image = CGImageSourceCreateImageAtIndex(source, $0, nil) {
                images.append(image)
            }
            let delaySeconds = UIImage.delay(forImageAtIndex: $0, source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }

        let duration = delays.reduce(into: 0) { $0 += $1 }

        let gcd = gcdForArray(delays)

        var frames: [UIImage] = []
        (0..<count).forEach {
            let frame = UIImage(cgImage: images[$0])
            let frameCount = Int(delays[$0] / gcd)
            frames.append(contentsOf: [UIImage](repeating: frame, count: frameCount))
        }

        let animation = UIImage.animatedImage(with: frames,
            duration: Double(duration) / 1000.0)

        return animation
    }
}

