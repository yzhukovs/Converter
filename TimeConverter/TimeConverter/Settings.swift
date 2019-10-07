//
//  Settings.swift
//  TimeConverter
//
//  Created by Yvette Zhukovsky on 9/20/19.
//  Copyright © 2019 bumnetworks. All rights reserved.
//

import SwiftUI
import Combine

enum Yards: Int, CaseIterable, Hashable, Identifiable  {
    var id: Yards {return self}
    case _50 = 50
    case _100 = 100
    case _200 = 200
    case _400 = 400
    case _500 = 500
    case _1000 = 1000
    case _1650 = 1650
}

enum Meters: Int, CaseIterable, Hashable, Identifiable {
    var id: Meters {return self}
    
    case _50 = 50
    case _100 = 100
    case _200 = 200
    case _400 = 400
    case _800 = 800
    case _1500 = 1500
}

enum Course: Hashable, Identifiable {
    func format() -> String {
        switch self {
        case .SCY(let y):
            return "SCY, Distance in Yards:  \(y.rawValue)"
        case .LCM (let m):
            return "LCM, Distance in Meters: \(m.rawValue)"
        case .SCM (let m):
            return "SCM, Distance in Meters: \(m.rawValue)"
        }
    }
    static func parse(_ s: String)-> Course? {
        let twoParts = s.components(separatedBy: "/")
        switch twoParts[0] {
        case "SCY":
            guard let yint = Int(twoParts[1]) else {return nil}
            guard let yards = Yards(rawValue: yint) else {return nil}
            return SCY(yards)
        case "SCM":
            guard let mint = Int(twoParts[1]) else {return nil}
            guard let meters = Meters(rawValue: mint) else {return nil}
            return SCM(meters)
        case "LCM":
            guard let mint = Int(twoParts[1]) else {return nil}
            guard let meters = Meters(rawValue: mint) else {return nil}
            return LCM(meters)
        default:
            break
        }
        
        return nil
    }
    
    func serialize()-> String {
        switch self {
               case .SCY(let y):
                   return "SCY/\(y.rawValue)"
               case .LCM (let m):
                   return "LCM/\(m.rawValue)"
               case .SCM (let m):
                   return "SCM/\(m.rawValue)"
               }
    }
    
    var id: Course {self}
    
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
    private static let MagicFactor3 = 1.25
    
    enum ShortCourseYardsToMeters {
        private static func scyToScm(_ time: Double, _ from: Course, _ to: Course) -> Double { return time * Conversions.MagicFactor1 }
        
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
        
        
        static func possibleConversions(_ from: Course) -> [(Course, (Double, Course, Course) -> Double)] {
            var possible = [(Course, (Double, Course, Course) -> Double)]()
            switch from {
            case (.SCY(let y)):
                possible.append(contentsOf: Meters.allCases.filter {$0.rawValue == y.rawValue}.map {(Course.SCM($0), scyToScm)})
                possible.append(contentsOf: Meters.allCases.filter {$0.rawValue == y.rawValue}.map {(Course.LCM($0), scyToLcmSameDistance)})
                switch y {
                case ._500: possible.append((Course.LCM(._400), scyToLcmLongDistance1))
                case ._1000: possible.append((Course.LCM(._800), scyToLcmLongDistance1))
                case ._1650: possible.append((Course.LCM(._1500), scyToLcmLongDistance2))
                default: break
                }
            case (.LCM(let m)):
                possible.append(contentsOf: Yards.allCases.filter {$0.rawValue == m.rawValue}.map {(Course.SCY($0), MetersToShortCourseYards.lcmToScySameDistace)})
                switch m {
                case ._400: possible.append((Course.SCY(._500), MetersToShortCourseYards.lcmToScyLongDistance1))
                case ._800: possible.append((Course.SCY(._1000), MetersToShortCourseYards.lcmToScyLongDistance1))
                case ._1500: possible.append((Course.SCY(._1650), MetersToShortCourseYards.lcmToScyLongDistance2))
                default: break
                }
            case (.SCM(let m)):
                possible.append(contentsOf: Yards.allCases.filter {$0.rawValue == m.rawValue}.map {(Course.SCY($0), MetersToShortCourseYards.convert)})
                
            }
            return possible
        }
    }
    
    enum MetersToShortCourseYards {
        static func convert(_ time: Double, _ from: Course, _ to: Course) -> Double {
            return time / Conversions.MagicFactor1
        }
        
        //Long course meters to short course yards:
        static func lcmToScySameDistace(_ time: Double, _ from: Course, _ to: Course) -> Double {
            let t = to.turns() - from.turns()
            return time - Double(t) / Conversions.MagicFactor1
        }
        static func lcmToScyLongDistance1(_ time: Double, _ from: Course, _ to: Course) -> Double {
            let t = to.turns() - from.turns()
            return (time - Double(t)/Conversions.MagicFactor1) * Conversions.MagicFactor3
        }
        static func lcmToScyLongDistance2(_ time: Double, _ from: Course, _ to: Course) -> Double {
            return time - 30.0
        }
        
        
        
        
    }
}


final class Settings: ObservableObject  {
    private enum Keys {
        static let course = "course"
    }
    
    let objectWillChange = PassthroughSubject<Void, Never>()
    private let cancellable: Cancellable
    private let defaults: UserDefaults
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        defaults.register(defaults: [
            Keys.course: Course.LCM(Meters._50)
            ])

        cancellable = NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .map { _ in () }
            .subscribe(objectWillChange)
    }
    
    var savedCourse: Course? {
        get {
            return defaults.string(forKey: Keys.course).flatMap{Course.parse($0)}
        }
        
        set {
            defaults.set(newValue?.serialize(), forKey: Keys.course)
            
        }
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
