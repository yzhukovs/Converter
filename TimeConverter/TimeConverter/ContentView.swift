//
//  ContentView.swift
//  NewTimeConverter
//
//  Created by Yvette Zhukovsky on 9/22/19.
//  Copyright © 2019 bumnetworks. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    
    @State private var fromCourse: Course = Course.SCY(._50)
    @State var enteredTime: Double?
    @State private var toCourse: Course = Course.SCY(._50)

    
    private let availableCourses: [Course] =
        Yards.allCases.map{Course.SCY($0)} +
            Meters.allCases.map{Course.LCM($0)} +
            Meters.allCases.map{Course.SCM($0)}
    
    func renderCourse(_ c: Course) -> some View {
        Text(String(describing: c.self)).tag(c.id)
    }
    
    func coursePicker(_ selection: Binding<Course>, _ label: Text, _ courses: [Course]) -> some View {
        Picker(selection: selection, label: label) {
            ForEach(courses) { dis in
                self.renderCourse(dis)
            }
        }
    }
    
    var section1: some View {
        Section {
            Text("From course").font(.headline)
            coursePicker($fromCourse, Text("Select from course"), availableCourses)
            
        }
    }
    

    
    var section2: some View {
        Section {
            Section {
                
                //TextField($enteredTime, label: Text("Enter Time:").font(.headline))
                Text("Time").font(.headline)
                TextField("1:23.45", value: $enteredTime, formatter: NumberFormatter())
                // Text("\(enteredTime)!")
                
            }
        }
    }
    
    func getConversion() -> ((Double, Course, Course) -> Double)? {
        Conversions.ShortCourseYardsToMeters.possibleConversions(fromCourse).first{
            $0.0 == toCourse
            }?.1
    }
    
    func performConversion()-> some View {
        guard let f = getConversion() else {return Text("Error")}
        guard let t = enteredTime else {return Text("")}
       
      return Text("\( f(t, fromCourse, toCourse))")
    }
    
    var section3: some View {
        Section {
            Section {
              Text("To course").font(.headline)
                coursePicker($toCourse, Text("Select to course"), Conversions.ShortCourseYardsToMeters.possibleConversions(fromCourse).map{$0.0})
                
            }
        }
    }
    
    var section4: some View {
        Section {
            Section {
              Text("Result").font(.headline)
            performConversion()
               
            }
        }
    }
    
    var body: some View {
        return NavigationView {
            
            Form {
                section1
                section2
                section3
                section4
            }.navigationBarTitle(Text("Swim Time Converter"))
            
        }
        
        
    }
    
    
    
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        ContentView(enteredTime: 0.0)
        
    }
}
