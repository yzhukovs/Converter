//
//  Settings.swift
//  TimeConverter
//
//  Created by Yvette Zhukovsky on 9/20/19.
//  Copyright © 2019 bumnetworks. All rights reserved.
//

import SwiftUI
import Combine

class Settings {
    private enum Keys {
        static let distance = "distance_key"
    }
    
    let objectWillChange = PassthroughSubject<Void, Never>()
    private let defaults: UserDefaults
    private let cancellable: Cancellable
    
    enum Distance: Int, CaseIterable, Hashable, Identifiable {
        var id: Distance {self}
        var distance: Int { return self.rawValue}
        case _50 = 50
        case _100 = 100
        case _200 = 200
        case _400 = 400
        case _800 = 800
        case _1500 = 1500
    }
    
    enum Stroke: String, CaseIterable, Hashable, Identifiable  {
        var id: Stroke {self}
        var style: String {return self.rawValue}
        case Backstroke
        case Butterfly
        case Breaststroke
        case Freestyle
        case IM
    }
    
    enum Course: String,  CaseIterable, Hashable, Identifiable {
        var id: Course {self}
        var course: String {return self.rawValue}
        case SCYards
        case LCMeters
    }
    
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaults.register(defaults: [
            Keys.distance: Distance._50.rawValue
        ])
        
        cancellable = NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .map { _ in () }
            .subscribe(objectWillChange)
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
}

//struct Settings_Previews: PreviewProvider {
//    static var previews: some View {
//        Settings()
//    }
//}
