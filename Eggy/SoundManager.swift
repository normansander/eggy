//
//  SoundManager.swift
//  Eggy
//
//  Created by Norman Sander on 22.07.15.
//  Copyright (c) 2015 Norman Sander. All rights reserved.
//

import Foundation
import AVFoundation

final class SoundManager {
    static let shared = SoundManager()

    var sounds: Dictionary<String, AVAudioPlayer> = Dictionary<String, AVAudioPlayer>()


    func register(_ name: String!, loops: Int = 0) {
        let path = Bundle.main.path(forResource: name, ofType: "mp3")
        let fileURL = URL(fileURLWithPath: path!)
        let sound: AVAudioPlayer!
        do {
            sound = try AVAudioPlayer(contentsOf: fileURL)
        } catch _ {
            sound = nil
        }
        sound!.numberOfLoops = loops
        sound!.prepareToPlay()
        self.sounds[name] = sound
    }

    func play(_ name: String!) {
        self.sounds[name]?.stop()
        self.sounds[name]?.currentTime = 0
        self.sounds[name]?.play()
    }

    func stop(_ name: String!) {
        self.sounds[name]?.stop()
    }
}
