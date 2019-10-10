//
//  Settings.swift
//  TimeConverter
//
//  Created by Yvette Zhukovsky on 9/20/19.
//  Copyright © 2019 bumnetworks. All rights reserved.
//

import SwiftUI
import Combine



final class Settings: ObservableObject  {
    private enum Keys {
        static let course = "course"
        // static let enteredTime = "enteredTime"
    }
    
    let objectWillChange = PassthroughSubject<Void, Never>()
    //private let cancellable: Cancellable
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        
        let d = SavingHistory(conversions: []).encodedData()
        defaults.register(defaults: [Keys.course : d ] )
        
        
        /*cancellable = NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .map { _ in () }
            .subscribe(objectWillChange)*/
    }
    
    var savedCourse: SavingHistory? {
        get {
            guard let data = defaults.data(forKey: Keys.course) else {
                print("no model for key: \(Keys.course)")
                return nil
            }
            
            do {
                let model = try JSONDecoder().decode(SavingHistory.self, from: data)
                return model
                
            } catch let error {
                print(error.localizedDescription)
                print(String(data: data, encoding: .utf8)!)
                return nil
            }
            
            
            // print("did load model for key: \(Keys.course)")
            
        }
        set {
            guard newValue != nil else {
                defaults.removeObject(forKey: Keys.course)
                return
            }
            
            guard let encodedData = newValue?.encodedData() else {return}
            defaults.set(encodedData, forKey:Keys.course )
            defaults.synchronize()
            //defaults.set(newValue?.serialize(), forKey: Keys.course)
        }
        
        
    }
    
    
    
}

struct History: Codable, Identifiable {
    
    var id: Event?
    
    let fromCourse: Event
    let toCourse: Event
    let timeEntered: String
    let timeConverted: String
    
    
}
struct SavingHistory: Codable {
    
    var conversions: [History]
    
    func encodedData() -> Data {
        return try! JSONEncoder().encode(self)
        
    }
    
}




