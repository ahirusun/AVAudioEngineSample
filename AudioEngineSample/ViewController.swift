//
//  ViewController.swift
//  AudioEngineSample
//
//  Created by ahirusun on 2016/06/10.
//  Copyright © 2016年 ahirusun. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    private var audioEngineMnager = AudioEngineManager()
    
    @IBOutlet private weak var recButton: UIButton!
    @IBOutlet private weak var playButton: UIButton!

    @IBAction func recButtonPushed() {
        if audioEngineMnager.status == .isPlaying { return }
        
        switch audioEngineMnager.status {
        case .Default:
            audioEngineMnager.record()
            recButton.setTitle("Rec Stop", forState: .Normal)
        case .isRecording:
            audioEngineMnager.stopRecord()
            recButton.setTitle("Rec Start", forState: .Normal)
        case .isPlaying: break
        }
    }
    
    @IBAction func playButtonPushed() {
        if audioEngineMnager.status == .isRecording { return }
        
        switch audioEngineMnager.status {
        case .Default:
            audioEngineMnager.playRecData()
            audioEngineMnager.audioPlayer?.delegate = self
            playButton.setTitle("Stop", forState: .Normal)
        case .isPlaying:
            audioEngineMnager.stopRecData()
            playButton.setTitle("Play", forState: .Normal)
        case .isRecording: break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // setUp audioEngine.
        audioEngineMnager.setup()
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            audioEngineMnager.status = .Default
            playButton.setTitle("Play", forState: .Normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

