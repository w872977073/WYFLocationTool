//
//  LocationTool.swift
//  LocationTool
//
//  Created by wyf on 2017/9/26.
//  Copyright © 2017年 FanFanKJ. All rights reserved.
//

import UIKit
import CoreLocation

// 定位完成回调闭包
typealias completeCallBack = ((_ location:CLLocation?,_ errorMsg:String?)->())?

class LocationTool: NSObject {
    // 完成回调闭包对象
    var completeCallback:completeCallBack
    // 设置单例
    static let shared = LocationTool()
    // 不让外界使用构造方法
    private override init() {
        
    }
    // 懒加载位置管理器
    lazy var locationM:CLLocationManager = {
        
        let locationM = CLLocationManager()
        locationM.delegate = self
        
        // 获取infoPlist字典
         let infoDic = Bundle.main.infoDictionary
        
        //  always 比 whenInUse的优先级高
        let whenInUse = infoDic!["NSLocationWhenInUseUsageDescription"]
        let always = infoDic!["NSLocationAlwaysUsageDescription"]
        
        // 系统适配
        if #available(iOS 8, *) {
            
            if always != nil{
                locationM.requestAlwaysAuthorization()
            }else if whenInUse != nil{
                locationM.requestWhenInUseAuthorization()
                
                // 判断后台模式是否打开 location update  UIBackgroundModes
                if let backgroundModes = infoDic!["BackgroundModes"] as? [String]{
                    // 判断后台是否开启  location update
                    if backgroundModes.contains("location"){
                        
                        if #available(iOS 9.0, *){
                            
                            locationM.allowsBackgroundLocationUpdates = true
                        }
                        
                    }

                }

            }else{
                print("到info.plist中补全")
            }
        }
        return locationM
    }()
 
    
    
    // 获取当前地址方法
    func locationToolGetCurrentLocation(resultBlock: completeCallBack){
        
        completeCallback = resultBlock
        
        locationM.startUpdatingLocation()
    }

}
// MARK:  CLLocationManagerDelegate
extension LocationTool:CLLocationManagerDelegate{
    
    // 更新位置
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let loc = locations.last else {
            if completeCallback != nil{
                
                completeCallback?(nil,"没有获取到位置")
            }
            
            return
        }
        guard let completeCallback = completeCallback else {
            return
        }

        completeCallback(loc,nil)
        locationM.stopUpdatingLocation()

    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        guard let completeCallback = completeCallback else {
            return
        }
        
        switch status {
        case .denied:
            completeCallback(nil, "当前被拒绝")
        case .restricted:
            completeCallback(nil, "当前受限制")
        case .notDetermined:
            completeCallback(nil, "用户还未决定")
        default:
            break
        }
        
    }
}
