//import CoreLocation
//
//
///// MARK: - AIRGoogleMapClient
//class AIRGoogleMapClient: AnyObject {
//
//    /// MARK: - property
//
//
//    /// MARK: - class method
//
//    static let sharedInstance = AIRGoogleMapClient()
//
//
//    /// MARK: - public api
//
//    /**
//     * request google map geocode API (https://developers.google.com/maps/documentation/geocoding/)
//     * @param location CLLocation
//     * @param completionHandler (json: JSON) -> Void
//     */
//    func getReverseGeocode(location location: CLLocation, completionHandler: (json: JSON) -> Void) {
//        // make request
//        let queries = [
//            "latlng" : "\(location.coordinate.latitude),\(location.coordinate.longitude)",
//            "key" : AIRGoogleMap.BrowserAPIKey
//        ]
//        let request = NSMutableURLRequest(URL: NSURL(URLString: AIRGoogleMap.API.GeoCode, queries: queries)!)
//
//        // request
//        let operation = ISHTTPOperation(request: request, handler:{ (response: NSHTTPURLResponse!, object: AnyObject!, error: NSError!) -> Void in
//                var responseJSON = JSON([:])
//                if object != nil { responseJSON = JSON(data: object as! NSData) }
//                dispatch_async(dispatch_get_main_queue(), {
//                    completionHandler(json: responseJSON)
//                })
//            }
//        )
//        AIRGoogleMapOperationQueue.defaultQueue().addOperation(operation)
//    }
//
//    /**
//     * cancel geocode API
//     **/
//    func cancelGetReverseGeocode() {
//        AIRGoogleMapOperationQueue.defaultQueue().cancelOperationsWithPath(NSURL(string: AIRGoogleMap.API.GeoCode)!.path)
//    }
//
//    /**
//     * request google map place nearbysearch API (https://developers.google.com/maps/documentation/geocoding/)
//     * @param location CLLocation
//     * @param completionHandler (json: JSON) -> Void
//     */
//    func getLocatoinNearBySearch(location location: CLLocation, completionHandler: (json: JSON) -> Void) {
//        // make request
//        let queries = [
//            "location" : "\(location.coordinate.latitude),\(location.coordinate.longitude)",
//            "radius" : "1",
//            "key" : AIRGoogleMap.BrowserAPIKey
//        ]
//        let request = NSMutableURLRequest(URL: NSURL(URLString: AIRGoogleMap.API.PlaceNearBySearch, queries: queries)!)
//
//        // request
//        let operation = ISHTTPOperation(request: request, handler:{ (response: NSHTTPURLResponse!, object: AnyObject!, error: NSError!) -> Void in
//                var responseJSON = JSON([:])
//                if object != nil { responseJSON = JSON(data: object as! NSData) }
//                dispatch_async(dispatch_get_main_queue(), {
//                    completionHandler(json: responseJSON)
//                })
//            }
//        )
//        AIRGoogleMapOperationQueue.defaultQueue().addOperation(operation)
//    }
//
//    /**
//     * cancel place nearbysearch API
//     **/
//    func cancelGetPlaceNearBySearch() {
//        AIRGoogleMapOperationQueue.defaultQueue().cancelOperationsWithPath(NSURL(string: AIRGoogleMap.API.PlaceNearBySearch)!.path)
//    }
//
//}
//
