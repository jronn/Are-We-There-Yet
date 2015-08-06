//
//  VoiceInputHandler.swift
//  Are We There Yet
//
//  Created by David Rönn on 2015-08-06.
//  Copyright © 2015 Josef Rönn. All rights reserved.
//

import Foundation


class VoiceInputHandler: NSObject,OEEventsObserverDelegate {
    
    
    var openEarsEventsObserver = OEEventsObserver()
    var lmPath: String?
    var dicPath: String?
    let synth = AVSpeechSynthesizer()
    
    var formatter:NSNumberFormatter!
    var destRouteManager:DestinationRouteManager!
    
    
    init(drm:DestinationRouteManager) {
        super.init()
        destRouteManager = drm
        
        formatter = NSNumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        
        initializeOpenEars()
    }
    
    
    private func initializeOpenEars() {        
        openEarsEventsObserver.delegate = self
        
        let lmGenerator = OELanguageModelGenerator()
        let words = ["AREWETHEREYET"]
        
        let name = "languageModelFiles"
        let err: NSError? = lmGenerator.generateLanguageModelFromArray(words, withFilesNamed: name, forAcousticModelAtPath: OEAcousticModel.pathToModel("AcousticModelEnglish"))
        
        if err == nil {
            lmPath = lmGenerator.pathToSuccessfullyGeneratedLanguageModelWithRequestedName(name)
            dicPath = lmGenerator.pathToSuccessfullyGeneratedDictionaryWithRequestedName(name)
        } else {
            print("Error: \(err!)")
        }
        
        do{
            try OEPocketsphinxController.sharedInstance().setActive(true)
        }
        catch {
            print("Failed to activate sphinxController")
        }
        
        OEPocketsphinxController.sharedInstance().startListeningWithLanguageModelAtPath(lmPath, dictionaryAtPath: dicPath, acousticModelAtPath: OEAcousticModel.pathToModel("AcousticModelEnglish"), languageModelIsJSGF: false)
    }
    
    
    func pocketsphinxDidReceiveHypothesis(hypothesis: String!, recognitionScore: String!, utteranceID: String!) {
        print("The received hypothesis is \(hypothesis) with a score of \(recognitionScore) and an ID of \(utteranceID)")
        
        let input = split(hypothesis.characters){$0 == " "}.map{String($0)}
        
        for i in 0..<input.count {
            if input[i] == "AREWETHEREYET" {
                let time = destRouteManager.getTimeRemaining()
                let hours = floor((time / (60*60)))
                let minutes = floor((time / 60) % 60)
                
                var response:String!
                
                if hours > 0 {
                    response = formatter.stringFromNumber(hours)! + " hours and " + formatter.stringFromNumber(round(minutes))! + " minutes"
                } else {
                    response = formatter.stringFromNumber(round(minutes))! + " minutes"
                }
                
                var preChat:String!
                
                if NSUserDefaults.standardUserDefaults().boolForKey("distanceAudio") {
                    if NSUserDefaults.standardUserDefaults().valueForKey("unitType") as! String == "km" {
                        preChat = formatter.stringFromNumber(round(destRouteManager.getDistanceRemaining()/1000))! + " kilometers remaining, "
                    } else {
                        preChat = formatter.stringFromNumber(round(destRouteManager.getDistanceRemaining() * 0.00062137))! + " miles remaining, "
                    }
                } else {
                    preChat = " "
                }
                
                let myUtterance = AVSpeechUtterance(string: preChat + "Estimated travel time is " + response)
                myUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                myUtterance.rate = 0.15
                myUtterance.volume = NSUserDefaults.standardUserDefaults().floatForKey("volume")
                synth.speakUtterance(myUtterance)
                break
            }
        }
    }
    
    
    func pocketsphinxDidStartListening() {
        print("Pocketsphinx is now listening.")
    }
    
    func pocketsphinxDidDetectSpeech() {
        print("Pocketsphinx has detected speech.")
    }
    
    func pocketsphinxDidDetectFinishedSpeech() {
        print("Pocketsphinx has detected a period of silence, concluding an utterance.")
    }
    
    func pocketsphinxDidStopListening() {
        print("Pocketsphinx has stopped listening.")
    }
    
    func pocketsphinxDidSuspendRecognition() {
        print("Pocketsphinx has suspended recognition.")
    }
    
    func pocketsphinxDidResumeRecognition() {
        print("Pocketsphinx has resumed recognition.")
    }
    
    func pocketsphinxDidChangeLanguageModelToFile(newLanguageModelPathAsString: String!, andDictionary newDictionaryPathAsString: String!) {
        print("Pocketsphinx is now using the following language model: \(newLanguageModelPathAsString) and the following dictionary: \(newDictionaryPathAsString)")
    }
    
    func pocketSphinxContinuousSetupDidFailWithReason(reasonForFailure: String!) {
        print("Listening setup wasn't successful and returned the failure reason: \(reasonForFailure)")
    }
    
    func pocketSphinxContinuousTeardownDidFailWithReason(reasonForFailure: String!) {
        print("Listening teardown wasn't successful and returned the failure reason: \(reasonForFailure)")
    }
    
    func testRecognitionCompleted() {
        print("A test file that was submitted for recognition is now complete.")
    }
}
