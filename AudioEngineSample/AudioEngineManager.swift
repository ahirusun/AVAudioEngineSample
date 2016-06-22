//
//  AudioEngineManager.swift
//  AudioEngineSample
//
//  Created by ahirusun on 2016/06/10.
//  Copyright © 2016年 ahirusun. All rights reserved.
//

import Foundation
import AVFoundation

class AudioEngineManager: NSObject {
    
    enum State {
        case Default
        case isRecording
        case isPlaying
    }
    
    // rec format
    let recSettings:[String : AnyObject] = [
        AVFormatIDKey: NSNumber(unsignedInt: kAudioFormatLinearPCM),
        AVEncoderAudioQualityKey : AVAudioQuality.High.rawValue,
        AVNumberOfChannelsKey: 1,
        AVSampleRateKey : 44100,
        AVLinearPCMBitDepthKey : 16
    ]
    
    var status: State = .Default
    var audioPlayer: AVAudioPlayer?
    
    private var audioEngine = AVAudioEngine()
    private var outputFile = AVAudioFile()
    
    override init() {
        super.init()
        setup()
    }
    
    func setup() {
        
        // AudioSession init
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
        } catch let error as NSError  {
            print("Error : \(error)")
        }
        
        // Mic -> Effect -> BusMixer
        let input = audioEngine.inputNode
        let mixer = audioEngine.mainMixerNode
        
        /**
         * you can connect one or more effectNode
         * 
    
         + example for connect three effectNode
         +
         +   // Reverb
         +   let reverb = AVAudioUnitReverb()
         +   reverb.loadFactoryPreset(.LargeRoom)
         +   audioEngine.attachNode(reverb)
         +
         +   // Delay
         +   let delay = AVAudioUnitDelay()
         +   delay.delayTime = 1
         +   audioEngine.attachNode(delay)
         +
         +   // EQ
         +   let eq = AVAudioUnitEQ()
         +   audioEngine.attachNode(eq)
         +
         +   // connect!
         +   audioEngine.connect(input!, to: reverb, format: input!.inputFormatForBus(0))
         +   audioEngine.connect(reverb, to: delay, format: input!.inputFormatForBus(0))
         +   audioEngine.connect(delay, to: eq, format: input!.inputFormatForBus(0))
         +   audioEngine.connect(eq, to: mixer, format: input!.inputFormatForBus(0))
         
         *
         */

        // Distortion
        let distortion = AVAudioUnitDistortion()
        distortion.loadFactoryPreset(.DrumsLoFi)
        audioEngine.attachNode(distortion)
        
        // connect one effectNode
        audioEngine.connect(input!, to: distortion, format: input!.inputFormatForBus(0))
        audioEngine.connect(distortion, to: mixer, format: input!.inputFormatForBus(0))
    }
    
    // URL for saved RecData
    func recFileURL() -> NSURL {
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as String
        let pathArray = [dirPath, "rec.caf"]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        return filePath!
    }
    
    // remove file
    func removeRecFile() {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        let path = url.URLByAppendingPathComponent("rec.caf").path!
        if manager.fileExistsAtPath(path) {
            try! manager.removeItemAtPath(path)
        }
    }
    
    // recording start
    func record() {
        status = .isRecording
        
        removeRecFile()
        
        // set outputFile
        outputFile = try! AVAudioFile(forWriting: recFileURL(), settings: recSettings)
        
        // writing recordingData
        let input = audioEngine.inputNode
        
        // if you want to output sound in recording, set "input?.volume = 1"
        input?.volume = 0
        
        input!.installTapOnBus(0, bufferSize: 4096, format: input!.inputFormatForBus(0)) { (buffer, when) in
            try! self.outputFile.writeFromBuffer(buffer)
        }
        
        // AVAudioEngine start
        if !audioEngine.running {
            do {
                try audioEngine.start()
            } catch let error as NSError {
                print("Couldn't start engine, \(error.localizedDescription)")
            }
        }
    }
    
    // recording stop
    func stopRecord() {
        status = .Default
        
        // audioEngine stop
        audioEngine.inputNode?.removeTapOnBus(0)
        audioEngine.stop()
    }
    
    // play sound
    func playRecData() {
        
        if outputFile.length == 0 { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: recFileURL())
            audioPlayer!.volume = 1.0
            audioPlayer!.prepareToPlay()
            audioPlayer!.play()
            
            status = .isPlaying
        } catch let error as NSError {
            print("Error : \(error)")
        }
    }
    
    // stop sound
    func stopRecData() {
        guard let player = audioPlayer else { return }
        player.stop()
        
        status = .Default
    }
}