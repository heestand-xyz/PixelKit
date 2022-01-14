//
//  Created by Anton Heestand on 2021-10-03.
//

import Foundation
import MapKit
import CoreLocation

extension MKCoordinateRegion {
    var isValid: Bool {
        get {
            let latitudeCenter = self.center.latitude
            let latitudeNorth = self.center.latitude + self.span.latitudeDelta / 2
            let latitudeSouth = self.center.latitude - self.span.latitudeDelta / 2

            let longitudeCenter = self.center.longitude
            let longitudeWest = self.center.longitude - self.span.longitudeDelta / 2
            let longitudeEast = self.center.longitude + self.span.longitudeDelta / 2

            let topLeft = CLLocationCoordinate2D(latitude: latitudeNorth, longitude: longitudeWest)
            let topCenter = CLLocationCoordinate2D(latitude: latitudeNorth, longitude: longitudeCenter)
            let topRight = CLLocationCoordinate2D(latitude: latitudeNorth, longitude: longitudeEast)

            let centerLeft = CLLocationCoordinate2D(latitude: latitudeCenter, longitude: longitudeWest)
            let centerCenter = CLLocationCoordinate2D(latitude: latitudeCenter, longitude: longitudeCenter)
            let centerRight = CLLocationCoordinate2D(latitude: latitudeCenter, longitude: longitudeEast)

            let bottomLeft = CLLocationCoordinate2D(latitude: latitudeSouth, longitude: longitudeWest)
            let bottomCenter = CLLocationCoordinate2D(latitude: latitudeSouth, longitude: longitudeCenter)
            let bottomRight = CLLocationCoordinate2D(latitude: latitudeSouth, longitude: longitudeEast)

            return  CLLocationCoordinate2DIsValid(topLeft) &&
                CLLocationCoordinate2DIsValid(topCenter) &&
                CLLocationCoordinate2DIsValid(topRight) &&
                CLLocationCoordinate2DIsValid(centerLeft) &&
                CLLocationCoordinate2DIsValid(centerCenter) &&
                CLLocationCoordinate2DIsValid(centerRight) &&
                CLLocationCoordinate2DIsValid(bottomLeft) &&
                CLLocationCoordinate2DIsValid(bottomCenter) &&
                CLLocationCoordinate2DIsValid(bottomRight) ?
                  true :
                  false
        }
    }
}
