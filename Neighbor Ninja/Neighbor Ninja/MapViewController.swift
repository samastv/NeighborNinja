import UIKit
import MapKit
import Foundation
import BTNavigationDropdownMenu


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var selectedCellLabel: UILabel!
    let addressLat = NSUserDefaults.standardUserDefaults().floatForKey("addressLat")
    let addressLng = NSUserDefaults.standardUserDefaults().floatForKey("addressLng")
    
    var menuView: BTNavigationDropdownMenu!

    @IBOutlet weak var mapView: MKMapView!
    
    var data: [[String: AnyObject]]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateWithData(data, animated: false)
        
        let items = ["Home", "Report", "View", "Settings", "Sign Off"]
        self.selectedCellLabel.text = items.first
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 255.0/255.0, green:100.0/255.0, blue:190.0/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, title: items[2], items: items)
        menuView.cellHeight = 50
        menuView.cellBackgroundColor = self.navigationController?.navigationBar.barTintColor
        menuView.cellSelectionColor = UIColor(red: 0.0/255.0, green:160.0/255.0, blue:195.0/255.0, alpha: 1.0)
        menuView.keepSelectedCellColor = true
        menuView.cellTextLabelColor = UIColor.whiteColor()
        menuView.cellTextLabelFont = UIFont(name: "Avenir-Heavy", size: 17)
        menuView.cellTextLabelAlignment = .Left // .Center // .Right // .Left
        menuView.arrowPadding = 15
        menuView.animationDuration = 0.5
        menuView.maskBackgroundColor = UIColor.blackColor()
        menuView.maskBackgroundOpacity = 0.3
        menuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            print("Did select item at index: \(indexPath)")
            self.selectedCellLabel.text = items[indexPath]
            if self.selectedCellLabel.text == "Report"{
                self.performSegueWithIdentifier("viewtoreport", sender: self)
            }
            if self.selectedCellLabel.text == "Home"{
                self.performSegueWithIdentifier("viewtohome", sender: self)
            }
            if self.selectedCellLabel.text == "Settings"{
                self.performSegueWithIdentifier("viewtosettings", sender: self)
            }
            if self.selectedCellLabel.text == "Sign Off"{
                NSUserDefaults.standardUserDefaults().setBool(false, forKey:"isUserLoggedIn")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.performSegueWithIdentifier("loginView", sender: self)
            }
        }
        self.navigationItem.titleView = menuView

    }
    
    func updateWithData(data: [[String: AnyObject]]!, animated: Bool) {
        
        // Remember the data because we may not be able to display it yet
        self.data = data
        
        if (!isViewLoaded()) {
            return
        }
        
        // Clear old annotations
        if mapView.annotations.count > 0 {
            let ex = mapView.annotations
            mapView.removeAnnotations(ex)
        }
        
        // Longitude and latitude accumulators so we can find the center
        var lata : CLLocationDegrees = 0.0
        var lona : CLLocationDegrees = 0.0
        
        
        // Create annotations for the data
        var anns : [MKAnnotation] = []
        for item in data {
            if let loc: AnyObject! = (item["location_1"]!) {
//                let lat = (item["latitude"]! as! NSString).doubleValue
//                let lon = (item["longitude"]! as! NSString).doubleValue
                
                let block: String = item["block"] as! String
                let city: String = item["city"] as! String
                let state: String = item["state"] as! String
                let locationString: String = "\(block) \(city) \(state)"
//                print (locationString)
                
                var geocoder: CLGeocoder = CLGeocoder()
                geocoder.geocodeAddressString(locationString,completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                    if (placemarks?.count > 0) {
                        var topResult: CLPlacemark = (placemarks?[0])!
                        var placemark: MKPlacemark = MKPlacemark(placemark: topResult)
                        let lat = placemark.coordinate.latitude
                        let lng = placemark.coordinate.longitude
                        let latUsed = Double(lat)
                        let lngUsed = Double(lng)
                        lata += latUsed
                        lona += lngUsed
                        let a = MKPointAnnotation()
                        a.title = item["crimedescription"]! as! String
                        a.coordinate = CLLocationCoordinate2D (latitude: latUsed, longitude: lngUsed)
                        anns.append(a)
                        
                        // Set the annotations and center the map
                        if (anns.count > 0) {
                            print (a.title)
                            self.mapView.addAnnotations(anns)
                            let w = 1.0 / Double(anns.count)
                            let r = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: latUsed, longitude: lngUsed), 2000, 2000)
                            self.mapView.setRegion(r, animated: animated)
                        }
                    }
                
                })
                
            }

    }

}


}