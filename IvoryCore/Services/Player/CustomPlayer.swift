//
//  CustomPlayer.swift
//  IvoryCore
//
//  Created by Ilya Kuznetsov on 16/03/2023.
//

import Foundation
import AVKit

public final class CustomPlayer: AVQueuePlayer {
    
    var interrupted: Bool = false
    var stopped: Bool = false
    
    public override var rate: Float {
        willSet {
            stopped = newValue == 0
            
            if !stopped {
                interrupted = false
            }
        }
    }
}
