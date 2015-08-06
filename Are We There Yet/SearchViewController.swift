//
//  SearchViewController.swift
//  Are We There Yet
//
//  Created by Josef Rönn on 2015-07-10.
//  Copyright © 2015 Josef Rönn. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation


class SearchViewController:UIViewController,UISearchBarDelegate {
    
    var searchController:UISearchController!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    
    var locManager:CLLocationManager!
    var destRouteManager:DestinationRouteManager!
    var destination:MKPlacemark!
    
    @IBOutlet weak var searchIcon: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        hideLoadingIndicator()
        hideSearchBar()
        showSearchIcon()
        
        locManager = CLLocationManager()
        locManager.requestAlwaysAuthorization()
        locManager.requestWhenInUseAuthorization()
        
        destRouteManager = DestinationRouteManager()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    
    
    @IBAction func searchIconPressed(sender: UIButton) {
        hideSearchIcon()
        showSearchBar()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        
        searchBar.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
        
        hideSearchBar()
        showLoadingIndicator()
        
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                self.hideLoadingIndicator()
                self.showErrorAlert("Place not found")
            } else {
                self.destRouteManager.initRouteDetails(localSearchResponse!.mapItems.first!.placemark, callback: { (routeFound:Bool) in
                    if routeFound {
                        self.performSegueWithIdentifier("routeView", sender: self)
                    } else {
                        self.hideLoadingIndicator()
                        self.showErrorAlert("Could not find a route to target")
                    }
                })
            }
        }
    }
    
    
    private func showErrorAlert(alertMessage:String) {
        showSearchBar()
        let alert = UIAlertController(title: nil, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel) { action -> Void in }
        alert.addAction(okAction)
        presentViewController(alert, animated:true, completion:nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "routeView") {
            let routeVC = (segue.destinationViewController as! RouteViewController)
            routeVC.destRouteManager = self.destRouteManager
            routeVC.locManager = self.locManager
            self.hideLoadingIndicator()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        showSearchIcon()
        
        // Make nav bar background transparent
        let nav = self.navigationController?.navigationBar
        nav?.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        nav?.shadowImage = UIImage()
        nav?.translucent = true
        
        // Nav text color
        nav?.tintColor = UIColor.whiteColor()
    }
    
    private func hideLoadingIndicator() {
        loadingIndicator.stopAnimating()
        loadingIndicator.hidden = true
    }
    
    private func showLoadingIndicator() {
        loadingIndicator.startAnimating()
        loadingIndicator.hidden = false
    }
    
    private func hideSearchBar() {
        searchBar.hidden = true
    }
    
    private func showSearchBar() {
        searchBar.hidden = false
        searchBar.becomeFirstResponder()
    }

    private func hideSearchIcon() {
        searchIcon.hidden = true
        searchIcon.enabled = false
    }
    
    private func showSearchIcon() {
        searchIcon.hidden = false
        searchIcon.enabled = true
    }
}
