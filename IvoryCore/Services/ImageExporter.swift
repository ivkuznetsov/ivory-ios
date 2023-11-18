//
//  ImageExporter.swift
//  YouPlayer
//
//  Created by Ilya Kuznetsov on 12/6/17.
//  Copyright © 2017 Ilya Kuznetsov. All rights reserved.
//

import Foundation
import AVKit
import MobileCoreServices
import CommonUtils

public struct ImageExporter {
    
    public func generateGIF(asset: AVAsset, time: CMTime) async throws -> URL {
        let fileProps = [kCGImagePropertyGIFDictionary : [kCGImagePropertyGIFLoopCount : 0, kCGImagePropertyGIFHasGlobalColorMap : true] as [CFString : Any]]
        let speed: Double = 15
        let delay = 1 / speed
        
        let frameProps = [kCGImagePropertyGIFDictionary : [kCGImagePropertyGIFDelayTime : delay]]
        
        let movieLength = min(Double(time.value) / Double(time.timescale), 5.0)
        let frameCount = Int(Double(movieLength) * speed)
        
        let inc = movieLength / Double(frameCount)
        
        let url = URL(fileURLWithPath: NSTemporaryDirectory() + "/snapshot.gif")
        try? FileManager.default.removeItem(at: url)
        
        let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.gif.identifier as CFString, frameCount, nil)!
        
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceAfter = CMTime(seconds: 0.01, preferredTimescale: time.timescale)
        generator.requestedTimeToleranceBefore = generator.requestedTimeToleranceAfter
        
        for frameNumber in 0..<frameCount {
            
            let seconds = inc * Double(frameNumber)
            let frameTime = CMTime(seconds: Double(time.value) / Double(time.timescale) - movieLength + seconds, preferredTimescale: time.timescale)
            
            let imageRef = try generator.copyCGImage(at: frameTime, actualTime: nil)
            let image = await UIImage(cgImage: imageRef).byPreparingThumbnail(ofSize: CGSize(width: 600, height: 600))!.cgImage!
            CGImageDestinationAddImage(destination, image, frameProps as CFDictionary)
        }
        
        CGImageDestinationSetProperties(destination, fileProps as CFDictionary)
        
        if CGImageDestinationFinalize(destination) {
            return url
        }
        throw RunError.custom("Cannot save file")
    }
}
