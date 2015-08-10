//
//  DestinationRouteManager.swift
//  Are We There Yet
//
//  Created by Josef Rönn on 2015-07-07.
//  Copyright © 2015 Josef Rönn. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class DestinationRouteManager : NSObject, CLLocationManagerDelegate {
    
    private var firstLoc:CLLocation!
    private var secondLoc:CLLocation!
    private var firstTime:NSDate!
    private var secondTime:NSDate!
    
    private var request:MKDirectionsRequest!
    
    private var destinationSet:Bool = false
    private var valid:Bool = false
    
    private var distanceRemaining:Double = 0
    private var timeRemaining:Double = 0
    private var route:MKRoute!
    internal var updateFlag = 0
    
    private var destination:MKPlacemark!
    
    var updateCount = 0
    
    // Update interval in seconds
    let UPDATE_INTERVAL = 60
    
    
    /*
    *   Called when route details to a destination is to be established, must be called after initializing class
    *   Returns the success of finding a route in the callback
    */
    func initRouteDetails(destPlacemark:MKPlacemark, callback:(routeFound:Bool) -> Void) {
        
        self.destination = destPlacemark
        
        request = MKDirectionsRequest()
        request.source = MKMapItem.mapItemForCurrentLocation()
        request.destination = MKMapItem(placemark: destPlacemark)
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        
        directions.calculateDirectionsWithCompletionHandler { response, error in
            if error != nil {
                print("Could not find route to destination")
                self.valid = false
            } else {
                self.distanceRemaining = round(response!.routes.first!.distance)
                self.timeRemaining = round(response!.routes.first!.expectedTravelTime)
                self.destinationSet = true
                self.route = (response?.routes.first!)!
                self.valid = true
            }
            self.updateFlag = 1
            callback(routeFound: self.valid)
        }
    }
    
    
    private func updateRoute() {
        request.source = MKMapItem.mapItemForCurrentLocation()
        let directions = MKDirections(request: request)
        
        directions.calculateDirectionsWithCompletionHandler { response, error in
            if error != nil {
                print("Could not update route to destination")
                self.valid = false
            } else {
                self.distanceRemaining = round(response!.routes.first!.distance)
                self.timeRemaining = round(response!.routes.first!.expectedTravelTime)
                self.route = (response?.routes.first!)!
                self.valid = true
            }
            self.updateFlag = 1
        }
    }
    
    
    func update(manager:CLLocationManager) {
        if destinationSet {
            if(secondLoc != nil) {
                firstLoc = secondLoc
            } else {
                firstLoc = manager.location
            }
            self.secondLoc = manager.location
            
            if(secondTime != nil) {
                firstTime = secondTime
            } else {
                firstTime = NSDate()
            }
            secondTime = NSDate()
            
            let distance = firstLoc.distanceFromLocation(secondLoc)
            distanceRemaining -= distance
            
            let time = secondTime.timeIntervalSinceDate(firstTime)
            timeRemaining -= time
            
            updateCount++
            
            // Force update of route calculation
            if updateCount >= UPDATE_INTERVAL {
                updateCount = 0
                updateRoute()
            }
        }
    }
    
    
    func isReady() -> Bool {
        return destinationSet
    }
    
    func getRoute() -> MKRoute {
        return route
    }
    
    // Returns true if information is considered valid (recently updated)
    func isValid() -> Bool {
        return valid
    }
    
    // Returns distance remaining in meters
    func getDistanceRemaining() -> Double {
        if distanceRemaining < 0 {
            return 0
        } else {
            return distanceRemaining
        }
    }
    
    // Returns time remaining in seconds
    func getTimeRemaining() -> Double {
        if timeRemaining < 0 {
            return 0
        } else {
            return timeRemaining
        }
    }
    
    func getDestination() -> String {
        var name:String = MKMapItem(placemark: destination).name!
        if name.characters.count > 10 {
            name = name.substringToIndex(advance(name.startIndex,14))
        }
        return name + ".."
    }
}