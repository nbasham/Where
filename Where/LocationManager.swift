import SwiftUI
import CoreLocation
import CoreLocationUI
import SwiftData

@Observable class LocationManager: NSObject, CLLocationManagerDelegate {
    /*@ObservationIgnored*/ private let manager = CLLocationManager()
    var location: CLLocationCoordinate2D?
//    @Query var locationList: LocationListModel
    let locationList: LocationListModel
    var locationCount: Int = 0
    var taskCount: Int = 0

    init(locations: [Location]? = nil) {
        let list: [Location]
        if let locations {
            list = locations
        } else {
            list = Location.loadLocations() ?? []
        }
        locationList = LocationListModel(locations: list)
        super.init()
        manager.delegate = self
        //        if manager.authorizationStatus != .authorizedAlways {
        manager.requestAlwaysAuthorization()
        //        }
        manager.pausesLocationUpdatesAutomatically = false // keep running when app out of focus
        manager.allowsBackgroundLocationUpdates = true
        manager.activityType = .otherNavigation
        manager.desiredAccuracy = kCLLocationAccuracyBest //kCLLocationAccuracyNearestTenMeters
    }

    func requestLocation() {
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status)
        if status == .authorizedWhenInUse {
            print("didChangeAuthorization")
            requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations")
        taskCount += 1
        if let location = locations.first {
            var locationHasChanged = true
            if let lastLocation = locationList.locations.last?.coordinate {
                locationHasChanged = !location.coordinate.isNearlyEqual(to: lastLocation)
            }
            guard locationHasChanged else {
                print("Location is the same as last recording, ignore.")
                return
            }
            locationList.append(Location(location))
            locationCount += 1
            print("Num locations stored \(locationList.locations.count)")
            //  TODO probably not efficient to save the list each time
            Location.saveLocations(locationList.locations)
        }
    }

    private var timer: DispatchSourceTimer?

    func startTimer() {
        let backgroundQueue = DispatchQueue(label: "com.where.backgroundQueue", qos: .background)
        timer = DispatchSource.makeTimerSource(queue: backgroundQueue)
        timer?.schedule(deadline: .now(), repeating: 1.0, leeway: .nanoseconds(0))
        timer?.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                self?.requestLocation()
                //                print("requestLocation()")
            }
        }
        timer?.resume()
    }

    func stopTimer() {
        timer?.cancel()
        timer = nil
    }
}

//@Model
class LocationListModel {

    private(set) var locations: [Location]

    init(locations: [Location]) {
        self.locations = locations
    }

    func append(_ location: Location) {
        locations.append(location)
    }
}
