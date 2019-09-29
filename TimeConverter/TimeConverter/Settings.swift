//
//  Settings.swift
//  TimeConverter
//
//  Created by Yvette Zhukovsky on 9/20/19.
//  Copyright © 2019 bumnetworks. All rights reserved.
//

import SwiftUI
import Combine

enum Yards: Int {
    case _50 = 50
    case _100 = 100
    case _200 = 200
    case _400 = 400
    case _500 = 500
    case _1000 = 1000
    case _1650 = 1650
}

enum Meters: Int {
    case _50 = 50
    case _100 = 100
    case _200 = 200
    case _400 = 400
    case _800 = 800
    case _1500 = 1500
}

enum Course {
    case SCY(Yards)
    case LCM(Meters)
    case SCM(Meters)
    
    private func baseAndDistance() -> (Int, Int) {
        switch self {
        case .SCY(let y): return (25, y.rawValue)
        case .LCM(let m): return (50, m.rawValue)
        case .SCM(let m): return (25, m.rawValue)
        }
    }
    
    func turns() -> Int {
        let (base, distance) = baseAndDistance()
        return (distance / base) - 1
    }
}

enum Conversions {
    private static let MagicFactor1 = 1.1
    private static let MagicFactor2 = 0.8
    
    enum ShortCourseYardsToMeters {
        private static func scyToScm(_ time: Double) -> Double { return time * Conversions.MagicFactor1 }
        
        private static func scyToLcmSameDistance(_ time: Double, _ from: Course, _ to: Course) -> Double {
            let t = to.turns() - from.turns()
            return time*Conversions.MagicFactor1 + Double(t)
        }
        
        private static func scyToLcmLongDistance1(_ time: Double, _ from: Course, _ to: Course) -> Double {
            let t = to.turns() - from.turns()
            return time*Conversions.MagicFactor1*Conversions.MagicFactor2 + Double(t)
        }
        
        private static func scyToLcmLongDistance2(_ time: Double, _ from: Course, _ to: Course) -> Double {
            return time + 30.0
        }
        
        static func convert(_ time: Double, _ from: Course, _ to: Course) -> Double? {
            switch (from, to) {
            case (.SCY(_), .SCM(_)): return scyToScm(time)
            case (.SCY(let y), .LCM(let m)):
                if y.rawValue == m.rawValue {
                    return scyToLcmSameDistance(time, from, to)
                } else {
                    switch (y, m) {
                    case (._500, ._400): return scyToLcmLongDistance1(time, from, to)
                    case (._1000, ._800): return scyToLcmLongDistance1(time, from, to)
                    case (._1650, ._1500): return scyToLcmLongDistance2(time, from, to)
                    default: return nil
                    }
                }
            default: return nil
            }
        }
    }
    
    enum MetersToShortCourseYards {
        static func convert(_ time: Double, _ from: Course, _ to: Course) -> Double? {
            return nil // XXX: implement me!
        }
    }
}

struct Event {
    let course: Course
    let stroke: Settings.Stroke
    
    func convert(time: Double /* XXX: some more specific time? */, to: Course) -> Double? {
        return nil // XXX: implement me
    }
}

class Settings {
    private enum Keys {
        static let distance = "distance_key"
    }
    
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    
    
    
    enum Distance: Int, CaseIterable, Hashable, Identifiable {
        var id: Distance {self}
        var distance: Int { return self.rawValue}
        case _50 = 50
        case _100 = 100
        case _200 = 200
        case _400 = 400
        case _500 = 500
        case _800 = 800
        case _1000 = 1000
        case _1500 = 1500
        
        var turns: Int? {
            switch self {
            case ._50: return 1
            case ._100: return 2
            case ._200: return 4
            case ._400: return 8
            case ._500: return 10
            case ._800: return 16
            case ._1000: return 20
            case ._1500: return 30
                
            }
        }
    }
    
    enum Stroke: String, CaseIterable, Hashable, Identifiable  {
        var id: Stroke {self}
        var style: String {return self.rawValue}
        case Backstroke
        case Butterfly
        case Breaststroke
        case Freestyle
        case IM
        
        var factor: Double? {
            switch self {
            case .Backstroke: return 0.6
            case .Breaststroke: return 1.0
            case . Butterfly: return 0.7
            case .IM: return 0.8
            case  .Freestyle: return 0.8
            }
        }
    }
    
    enum Course: String,  CaseIterable, Hashable, Identifiable {
        var id: Course {self}
        var course: String {return self.rawValue}
        case SCYards
        case LCMeters
        
    }
}


//    var distance: Distance {
//        get {
//            return Settings.Distance(rawValue: defaults.integer(forKey: Keys.distance)) ?? ._50
//        }
//
//        set {
//            defaults.set(newValue.rawValue, forKey: Keys.distance)
//        }
//    }
//


//struct Settings_Previews: PreviewProvider {
//    static var previews: some View {
//        Settings()
//    }
//}
