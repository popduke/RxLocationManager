//
//  AppDelegate.swift
//  RxLocationManagerDemo
//
//  Created by Yonny Hao on 16/7/10.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//

import UIKit
import CoreLocation

extension NSError{
    open override var description: String{
        get{
            switch domain {
            case "kCLErrorDomain":
                switch CLError(_nsError:self).code {
                case .locationUnknown:
                    return "Location Unknown"
                case .denied:
                    return "Denied"
                case .network:
                    return "Network"
                case .headingFailure:
                    return "Heading Failure"
                case .regionMonitoringDenied:
                    return "Region Monitoring Denied"
                case .regionMonitoringFailure:
                    return "Region Monitoring Failure"
                case .regionMonitoringSetupDelayed:
                    return "Region Monitoring Setup Delayed"
                case .regionMonitoringResponseDelayed:
                    return "Region Monitoring Response Delayed"
                case .geocodeFoundNoResult:
                    return "Geocode Found No Result"
                case .geocodeFoundPartialResult:
                    return "Geocode Found Partial Result"
                case .geocodeCanceled:
                    return "Geocode Canceled"
                case .deferredFailed:
                    return "Deferred Failed"
                case .deferredNotUpdatingLocation:
                    return "Deferred Not Updating Location"
                case .deferredAccuracyTooLow:
                    return "Deferred Accuracy Too Low"
                case .deferredDistanceFiltered:
                    return "Deferred Distance Filtered"
                case .deferredCanceled:
                    return "Deferred Canceled"
                case .rangingUnavailable:
                    return "Ranging Unavailable"
                case .rangingFailure:
                    return "Ranging Failure"
                }
            default:
                return self.description
            }
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

