//
//  ViewController.swift
//  Are We There Yet
//
//  Created by Josef Rönn on 2015-06-28.
//  Copyright © 2015 Josef Rönn. All rights reserved.
//
import Foundation
import UIKit
import CoreLocation
import MapKit

class RouteViewController: UIViewController,CLLocationManagerDelegate, MKMapViewDelegate {
    
    var destRouteManager:DestinationRouteManager!
    var locManager:CLLocationManager!
    
    var voiceEnabled = true
    var distanceVoice = false
    var volume:Float = 1.0
    var unitType:String = "km"
    var showDistance = false
    var showTime = false
    
    var formatter:NSNumberFormatter!
    var voiceInputHandler:VoiceInputHandler!
    
    @IBOutlet weak var infoLabel: CustomLabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var voiceButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        voiceInputHandler = VoiceInputHandler(drm:destRouteManager)
        initializeLocationService()
        
        map.zoomEnabled = false
        map.scrollEnabled = false
        map.userInteractionEnabled = false
        
        errorLabel.hidden = true
        voiceButton.layer.cornerRadius = 50
        voiceButton.layer.masksToBounds = true
        
        formatter = NSNumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func voiceButtonPressed(sender: AnyObject) {
        
        if voiceEnabled {
            voiceEnabled = false
            self.voiceButton.setImage(UIImage(named: "micoff.png"), forState: .Normal)
            OEPocketsphinxController.sharedInstance().suspendRecognition()
        } else {
            voiceEnabled = true
            self.voiceButton.setImage(UIImage(named: "micon.png"), forState: .Normal)
            OEPocketsphinxController.sharedInstance().resumeRecognition()
        }
    }
    
    
    @IBAction func infoButtonPressed(sender: UIButton) {
        let alertMessage = "Say the phrase 'Are we there yet' when the microphone is listening to get an audio response of the travel information"
        
        let alert = UIAlertController(title: nil, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel) { action -> Void in }
        alert.addAction(okAction)
        presentViewController(alert, animated:true, completion:nil)
    }
    
    
    private func applySettings() {
        
        showDistance = NSUserDefaults.standardUserDefaults().boolForKey("distanceDisplay")
        showTime = NSUserDefaults.standardUserDefaults().boolForKey("timeDisplay")
        
        infoLabel.hidden = !(showDistance || showTime)
        
        distanceVoice = NSUserDefaults.standardUserDefaults().boolForKey("distanceAudio")
        volume = NSUserDefaults.standardUserDefaults().floatForKey("volume")
        unitType = NSUserDefaults.standardUserDefaults().valueForKey("unitType") as! String
        
        forceLocationManagerUpdate()
    }
    
    
    private func initializeLocationService() {
        
        if(CLLocationManager.locationServicesEnabled()) {
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            locManager.startUpdatingLocation()
            
            map.delegate = self
            map.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true);
            showLoadIndicator()
        }
    }
    
    
    func mapView(mapView: MKMapView, rendererForOverlay
        overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            
            renderer.strokeColor = UIColor.blueColor()
            renderer.lineWidth = 3.0
            return renderer
    }
    
    
    func showRoute(route: MKRoute) {
        map.removeOverlays(map.overlays)
        map.addOverlay(route.polyline,level: MKOverlayLevel.AboveRoads)
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if(destRouteManager.isReady()) {
            destRouteManager.update(manager)
            
            if destRouteManager.updateFlag == 1 {
                
                destRouteManager.updateFlag = 0
                showRoute(destRouteManager.getRoute())
                
                if destRouteManager.isValid() {
                    errorLabel.hidden = true
                } else {
                    errorLabel.hidden = false
                }
            }
            
            var infoText = ""
            
            if showDistance {
                if unitType == "km" {
                    infoText += formatter.stringFromNumber(round(destRouteManager.getDistanceRemaining()/1000))! + " km to " + destRouteManager.getDestination()
                } else {
                    infoText += formatter.stringFromNumber(round(destRouteManager.getDistanceRemaining() * 0.00062137))! + " miles to " + destRouteManager.getDestination()
                }
            }
            
            if showTime {
                if showDistance {
                    infoText += "\n"
                }
                let time = destRouteManager.getTimeRemaining()
                let hours = floor((time / (60*60)))
                let minutes = floor((time / 60) % 60)
                
                if hours > 0 {
                    infoText += "ETA: " + formatter.stringFromNumber(hours)! + "h " + formatter.stringFromNumber(minutes)! + " min"
                } else {
                    infoText += "ETA: " + formatter.stringFromNumber(minutes)! + " min"
                }
            }
            
            infoLabel.text = infoText
            hideLoadIndicator()
        }
    }
    
    
    func locationManager(manager: CLLocationManager,didFailWithError error: NSError){
        print("Error while updating location" + error.localizedDescription)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        applySettings()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        if(self.isMovingFromParentViewController()) {
            locManager.stopUpdatingLocation()
            OEPocketsphinxController.sharedInstance().stopListening()
        }
    }
    
    
    private func showLoadIndicator() {
        loadingIndicator.hidden = false
        loadingIndicator.startAnimating()
    }
    
    
    private func hideLoadIndicator() {
        loadingIndicator.hidden = true
        loadingIndicator.stopAnimating()
    }
    
    
    private func forceLocationManagerUpdate() {
        locManager.stopUpdatingLocation()
        locManager.startUpdatingLocation()
    }
}

