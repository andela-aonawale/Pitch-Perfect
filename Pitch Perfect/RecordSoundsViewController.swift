//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Ahmed Onawale on 10/19/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    private var audioRecorder: AVAudioRecorder!
    
    @IBOutlet weak var recordingInProgress: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var pauseButtton: UIButton!

    @IBAction func recordAudio(sender: UIButton) {
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        toggleControls()
    }
    
    @IBAction func stopRecording(sender: UIButton) {
        toggleControls()
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func pauseRecording(sender: UIButton) {
        // we check if the audioRecorded is currently recording
        if audioRecorder.recording {
            audioRecorder.pause()
            toggleControls()
        }
    }
    
    private func toggleControls() {
        stopButton.hidden = !stopButton.hidden
        recordButton.enabled = !recordButton.enabled
        pauseButtton.hidden = !pauseButtton.hidden
        recordingInProgress.text = (recordButton.enabled ? "Tap to Record" : "recording in progress")
    }
    
    // MARK: - AVAudioRecorderDelegate
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        // if the recording was successful, we pass the recorded audio to the second view.
        if flag {
            let recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent!)
            performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        } else {
            // we show an alert indicating that the recording was not successful.
            let alert = UIAlertController(title: "Recording was not successful", message: nil, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            toggleControls()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destinationViewController as! PlaySoundsViewController
            playSoundsVC.receivedAudio = sender as! RecordedAudio
        }
    }
    
    // MARK: - View Controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let recordingName = "my_audio.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioRecorder = AVAudioRecorder(URL: filePath!, settings: [:])
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        stopButton.hidden = true
        recordButton.enabled = true
        pauseButtton.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

