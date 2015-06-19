//
//  SearchPlacesOperation.swift
//  MyMaps
//
//  Created by James Tang on 16/6/15.
//  Copyright (c) 2015 James Tang. All rights reserved.
//

import UIKit
import MapKit

public class BaseOperation : NSOperation {

    internal var _executing : Bool = false
    internal var _finished : Bool = false

    final override public var executing : Bool {
        get {
            return _executing
        }
    }

    final override public var finished : Bool {
        get {
            return _finished
        }
    }

    final override public func main() {
        execute()
    }

    func execute() {
        _executing = true
    }

    internal func completeOperation() {
        self.willChangeValueForKey("isFinished")
        self.willChangeValueForKey("isExecuting")
        _executing = true
        _finished = true
        self.didChangeValueForKey("isFinished")
        self.didChangeValueForKey("isExecuting")
    }

}

//public class GenericOperation<Result, Error> : BaseOperation {
//
//    public typealias CompletionHandler = (result: Result?, error: Error?)->()
//    private var result : Result?
//    private var error : Error?
//
//    private var executeHandler: ((completion:CompletionHandler)->())
//
//    public init(executeHandler:((completion:CompletionHandler)->())) {
//        self.executeHandler = executeHandler
//    }
//
//    public var completion:CompletionHandler? {
//        didSet {
//            self.completionBlock = {
//                if let completion = self.completion {
//                    completion(result: self.result, error: self.error)
//                }
//            }
//        }
//    }
//
//    public override func execute() {
//        _executing = true
//        _
//        self.executeHandler { (result, error) -> () in
//            self.completeOperation()
//        }
//    }
//
//}

public class SearchPlacesOperation:BaseOperation {

    public typealias Response = [Place]
    public typealias Error = NSError
    public typealias CompletionHandler = (response: Response?, error: Error?)->()
    public var completion : CompletionHandler? {
        didSet {
            self.completionBlock = {
                if let completion = self.completion {

                    var places : [Place]?
                    if let response = self.response {
                        places = []
                        for mapItem in response.mapItems {
                            places?.append(Place(mapItem: mapItem))
                        }
                    }

                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(response: places, error: self.error)
                    })
                }
            }
        }
    }
    
    private let address : String
    private let region : MKCoordinateRegion
    private var response : MKLocalSearchResponse?
    private var error: Error?

    public init(address: String, region: MKCoordinateRegion) {
        self.address = address
        self.region = region
    }

    public override func execute() {
        super.execute()
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = self.address
        request.region = self.region
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { (response, error) -> Void in
            self.response = response
            self.error = error
            self.completeOperation()
        }
    }
}
