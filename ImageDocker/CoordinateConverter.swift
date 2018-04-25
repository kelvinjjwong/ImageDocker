//
//  CoordinateConverter.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/23.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import CoreLocation
extension CLLocationCoordinate2D {
    
    // TODO: if out of china mainland, should use original coordinate
    
    struct GCJ02Constant {
        static let A = 6378245.0
        static let EE = 0.00669342162296594323
    }
    func GCJ02Offset() -> CLLocationCoordinate2D {
        let x = self.longitude - 105.0
        let y = self.latitude - 35.0
        let latitude = (-100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x))) +
            ((20.0 * sin(6.0 * x * .pi) + 20.0 * sin(2.0 * x * .pi)) * 2.0 / 3.0) +
            ((20.0 * sin(y * .pi) + 40.0 * sin(y / 3.0 * .pi)) * 2.0 / 3.0) +
            ((160.0 * sin(y / 12.0 * .pi) + 320 * sin(y * .pi / 30.0)) * 2.0 / 3.0)
        let longitude = (300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x))) +
            ((20.0 * sin(6.0 * x * .pi) + 20.0 * sin(2.0 * x * .pi)) * 2.0 / 3.0) +
            ((20.0 * sin(x * .pi) + 40.0 * sin(x / 3.0 * .pi)) * 2.0 / 3.0) +
            ((150.0 * sin(x / 12.0 * .pi) + 300.0 * sin(x / 30.0 * .pi)) * 2.0 / 3.0)
        let radLat = 1 - self.latitude / 180.0 * .pi;
        var magic = sin(radLat);
        magic = 1 - GCJ02Constant.EE * magic * magic
        let sqrtMagic = sqrt(magic);
        let dLat = (latitude * 180.0) / ((GCJ02Constant.A * (1 - GCJ02Constant.EE)) / (magic * sqrtMagic) * .pi);
        let dLon = (longitude * 180.0) / (GCJ02Constant.A / sqrtMagic * cos(radLat) * .pi);
        return CLLocationCoordinate2DMake(dLat, dLon);
    }
    
    fileprivate func convertWGS84toGCJ02(_ wgs84Point:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let offsetPoint:CLLocationCoordinate2D = wgs84Point.GCJ02Offset()
        let resultPoint:CLLocationCoordinate2D = CLLocationCoordinate2DMake(wgs84Point.latitude + offsetPoint.latitude, wgs84Point.longitude + offsetPoint.longitude)
        return resultPoint
    }
    
    fileprivate func convertGCJ02toWGS84(_ gcj02Point:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let mgPoint:CLLocationCoordinate2D = convertWGS84toGCJ02(gcj02Point)
        let resultPoint:CLLocationCoordinate2D = CLLocationCoordinate2DMake(gcj02Point.latitude * 2 - mgPoint.latitude,gcj02Point.longitude * 2 - mgPoint.longitude)
        return resultPoint;
    }
    
    fileprivate func convertGCJ02toBD09(_ gcj02Point:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let x = gcj02Point.longitude
        let y = gcj02Point.latitude
        let z = sqrt(x * x + y * y) + 0.00002 * sin(y * .pi);
        let theta = atan2(y, x) + 0.000003 * cos(x * .pi);
        let resultPoint:CLLocationCoordinate2D = CLLocationCoordinate2DMake(z * sin(theta) + 0.006, z * cos(theta) + 0.0065)
        return resultPoint
    }
    
    fileprivate func convertBD09toGCJ02(_ bd09Point:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let x = bd09Point.longitude - 0.0065
        let y = bd09Point.latitude - 0.006
        let z = sqrt(x * x + y * y) - 0.00002 * sin(y * .pi);
        let theta = atan2(y, x) - 0.000003 * cos(x * .pi);
        let resultPoint:CLLocationCoordinate2D = CLLocationCoordinate2DMake(z * sin(theta), z * cos(theta))
        return resultPoint
    }
    
    public func fromWGS84toGCJ02() -> CLLocationCoordinate2D {
        return self.convertWGS84toGCJ02(self)
    }
    
    public func fromWGS84toBD09() -> CLLocationCoordinate2D {
        let gcj02Point:CLLocationCoordinate2D = self.convertWGS84toGCJ02(self)
        return self.convertGCJ02toBD09(gcj02Point)
    }
    
    public func fromGCJ02toWGS84() -> CLLocationCoordinate2D {
        return self.convertGCJ02toWGS84(self)
    }
    
    public func fromGCJ02toBD09() -> CLLocationCoordinate2D {
        return self.convertGCJ02toBD09(self)
    }
    
    public func fromBD09toGCJ02() -> CLLocationCoordinate2D {
        return self.convertBD09toGCJ02(self)
    }
    
    public func fromBD09toWGS84(_ bd09Point:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let gcj02Point:CLLocationCoordinate2D = self.convertBD09toGCJ02(bd09Point)
        return self.convertGCJ02toBD09(gcj02Point)
    }
}
