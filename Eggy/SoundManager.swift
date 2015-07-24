//
//  SoundManager.swift
//  Eggy
//
//  Created by Norman Sander on 22.07.15.
//  Copyright (c) 2015 Norman Sander. All rights reserved.
//

import Foundation
import AVFoundation

class SoundManager {
    
    var sounds: Dictionary<String, AVAudioPlayer> = Dictionary<String, AVAudioPlayer>()
    
    class var sharedInstance: SoundManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: SoundManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = SoundManager()
        }
        return Static.instance!
    }
    
    func register(name: String!, loops: Int = 0) {
        let path = NSBundle.mainBundle().pathForResource(name, ofType:"mp3")
        let fileURL = NSURL(fileURLWithPath: path!)
        let sound = AVAudioPlayer(contentsOfURL: fileURL, error: nil)
        sound!.numberOfLoops = loops
        sound!.prepareToPlay()
        self.sounds[name] = sound
    }
    
    func play(name: String!) {
        self.sounds[name]?.stop()
        self.sounds[name]?.currentTime = 0
        self.sounds[name]?.play()
    }
    
    func stop(name: String!) {
        self.sounds[name]?.stop()
    }
}