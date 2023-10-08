import Foundation
import CoreLocation

// COORDINATE ------------------------------------------------

extension CLLocationCoordinate2D: Codable {
    public enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try values.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try values.decode(CLLocationDegrees.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    static let zero = CLLocationCoordinate2D(latitude: 0, longitude: 0)
}


extension Array where Element == CLLocationCoordinate2D {
    var minLatitude: CLLocationDegrees  { map {$0.latitude}.min() ?? 0}
    var maxLatitude: CLLocationDegrees  { map {$0.latitude}.max() ?? 0}
    var minLongitude: CLLocationDegrees { map {$0.longitude}.min() ?? 0}
    var maxLongitude: CLLocationDegrees { map {$0.longitude}.max() ?? 0}
}

extension Array where Element == CLLocation {
    var centerCoordinate: CLLocationCoordinate2D {
        let summedLatitudes = map {$0.coordinate.latitude}.reduce(0, +)
        let summedLongitudes = map {$0.coordinate.longitude}.reduce(0, +)
        return CLLocationCoordinate2D(latitude: summedLatitudes/Double(self.count), longitude: summedLongitudes/Double(self.count))
    }
}

// LOCATION ------------------------------------------------

struct Location {
    let coordinate: CLLocationCoordinate2D
    let altitude: CLLocationDistance
    let horizontalAccuracy: CLLocationAccuracy
    let verticalAccuracy: CLLocationAccuracy
    let course: CLLocationDirection
    let speed: CLLocationSpeed
    let timestamp: Date

    public init(coordinate: CLLocationCoordinate2D, altitude: CLLocationDistance, horizontalAccuracy: CLLocationAccuracy, verticalAccuracy: CLLocationAccuracy, course: CLLocationDirection, speed: CLLocationSpeed, timestamp: Date) {
        self.coordinate = coordinate
        self.altitude = altitude
        self.horizontalAccuracy = horizontalAccuracy
        self.verticalAccuracy = verticalAccuracy
        self.course = course
        self.speed = speed
        self.timestamp = timestamp
    }
    
    public init(_ location: CLLocation) {
        self.init(coordinate: location.coordinate, altitude: location.altitude, horizontalAccuracy: location.horizontalAccuracy, verticalAccuracy: location.verticalAccuracy, course: location.course, speed: location.speed, timestamp: location.timestamp)
    }
}

extension Location {
    var location: CLLocation {
        CLLocation(coordinate: coordinate, altitude: altitude, horizontalAccuracy: horizontalAccuracy, verticalAccuracy: verticalAccuracy, timestamp: timestamp)
    }
}

extension Location: Codable {
    public enum CodingKeys: String, CodingKey {
        case coordinate
        case altitude
        case horizontalAccuracy
        case verticalAccuracy
        case course
        case speed
        case timestamp
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coordinate, forKey: .coordinate)
        try container.encode(altitude, forKey: .altitude)
        try container.encode(horizontalAccuracy, forKey: .horizontalAccuracy)
        try container.encode(verticalAccuracy, forKey: .verticalAccuracy)
        try container.encode(course, forKey: .course)
        try container.encode(speed, forKey: .speed)
        try container.encode(timestamp, forKey: .timestamp)
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let coordinate = try values.decode(CLLocationCoordinate2D.self, forKey: .coordinate)
        let altitude = try values.decode(CLLocationDistance.self, forKey: .altitude)
        let horizontalAccuracy = try values.decode(CLLocationAccuracy.self, forKey: .horizontalAccuracy)
        let verticalAccuracy = try values.decode(CLLocationAccuracy.self, forKey: .verticalAccuracy)
        let course = try values.decode(CLLocationDirection.self, forKey: .course)
        let speed = try values.decode(CLLocationSpeed.self, forKey: .speed)
        let timestamp = try values.decode(Date.self, forKey: .timestamp)
        self.init(coordinate: coordinate, altitude: altitude, horizontalAccuracy: horizontalAccuracy, verticalAccuracy: verticalAccuracy, course: course, speed: speed, timestamp: timestamp)
    }

    // Save the array of Location objects to a file
    static func saveLocations(_ locations: [Location]) {
        do {
            let fileURL = try fileURLForLocations()
            let data = try JSONEncoder().encode(locations)
            try data.write(to: fileURL, options: [.atomicWrite])
        } catch {
            print("Error saving locations: \(error)")
        }
    }

    // Load the array of Location objects from a file
    static func loadLocations() -> [Location]? {
        do {
            let fileURL = try fileURLForLocations()
            let data = try Data(contentsOf: fileURL)
            let locations = try JSONDecoder().decode([Location].self, from: data)
            return locations
        } catch {
            print("Error loading locations: \(error)")
            return nil
        }
    }

    // Helper function to get the file URL for storing the locations
    static func fileURLForLocations() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("locations.json")
    }
}
