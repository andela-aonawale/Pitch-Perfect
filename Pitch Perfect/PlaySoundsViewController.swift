//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Ahmed Onawale on 10/19/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    private let audioPlayerNode = AVAudioPlayerNode()
    private let pitchEffect = AVAudioUnitTimePitch()
    private let distortionEffect = AVAudioUnitDistortion()
    private let speedEffect = AVAudioUnitVarispeed()
    private let echoEffect = AVAudioUnitDelay()
    
    private var audioFile:AVAudioFile!
    var receivedAudio: RecordedAudio!
    private var audioEngine: AVAudioEngine!
    
    // MARK: - Play Audio With Different Effects

    @IBAction func playSlowAudio(sender: UIButton) {
        playAudioWithPitch(nil, rate: 0.5, echo: nil, distort: nil, feedback: nil)
    }
    
    @IBAction func playFastAudio(sender: UIButton) {
        playAudioWithPitch(nil, rate: 2.0, echo: nil, distort: nil, feedback: nil)
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        playAudioWithPitch(1000, rate: nil, echo: nil, distort: nil, feedback: nil)
    }
    
    @IBAction func playDarthvaderAudio(sender: UIButton) {
        playAudioWithPitch(-1000, rate: nil, echo: nil, distort: nil, feedback: nil)
    }
    
    @IBAction func playEchoAudio(sender: UIButton) {
        playAudioWithPitch(nil, rate: nil, echo: 0.25, distort: nil, feedback: 25)
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        stopAudioEngine()
    }
    
    private func stopAudioEngine() {
        // stop all audio and reset engine
        audioEngine.stop()
        audioEngine.reset()
        audioPlayerNode.stop()
    }
    
    private func playAudioWithPitch(pitch: Float?, rate: Float?, echo: Float?, distort: Float?, feedback: Float?) {
        stopAudioEngine()
        // Set audioEngine parameters
        pitchEffect.pitch = pitch ?? 1
        speedEffect.rate = rate ?? 1
        echoEffect.delayTime = NSTimeInterval(echo ?? 0)
        echoEffect.feedback = feedback ?? 0
        distortionEffect.wetDryMix = distort ?? 0
        
        // Chain our nodes together and plays the audio
        audioEngine.connect(audioPlayerNode, to: pitchEffect, format: nil)
        audioEngine.connect(pitchEffect, to: speedEffect, format: nil)
        audioEngine.connect(speedEffect, to: distortionEffect, format: nil)
        audioEngine.connect(distortionEffect, to: echoEffect, format: nil)
        audioEngine.connect(echoEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)

        do {
            try audioEngine.start()
            audioPlayerNode.play()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - View Controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioEngine = AVAudioEngine()
        // attach all nodes to the audioEngine
        audioEngine.attachNode(audioPlayerNode)
        audioEngine.attachNode(pitchEffect)
        audioEngine.attachNode(distortionEffect)
        audioEngine.attachNode(speedEffect)
        audioEngine.attachNode(echoEffect)
        do {
            audioFile = try AVAudioFile(forReading: receivedAudio.filePathUrl)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
