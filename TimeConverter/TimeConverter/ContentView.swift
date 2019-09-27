//
//  ContentView.swift
//  NewTimeConverter
//
//  Created by Yvette Zhukovsky on 9/22/19.
//  Copyright © 2019 bumnetworks. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    
    
    @State private var selectedDistance = Settings.Distance._50
    @State private var selectedStroke = Settings.Stroke.Freestyle
    @State private var selectedCourse = Settings.Course.SCYards
    @State  var enteredTime: Double?
    
   
    
    var section1: some View {
        Section {
            Text("Distance and stroke").font(.headline)
            Picker(selection: $selectedDistance, label: Text("Select distance")) {
                ForEach(Settings.Distance.allCases) { dis in
                    Text("\(dis.rawValue)").tag(dis)
                }
            }
            
            Picker(selection: $selectedStroke, label: Text("Select stroke style")) {
                ForEach(Settings.Stroke.allCases) { stroke in
                    Text(stroke.rawValue).tag(stroke)
                }
            }
            
        }
    }
    
    var section2: some View {
        Section {
            Text("Course").font(.headline)
            Picker(selection: $selectedCourse, label: Text("From")) {
                ForEach(Settings.Course.allCases) { course in
                    Text(course.rawValue).tag(course)
                }
            }
            Picker(selection: $selectedCourse, label: Text("To")) {
                ForEach(Settings.Course.allCases) { course in
                    Text(course.rawValue).tag(course)
                }
            }
        }
    }
    
    var section3: some View {
        Section {
            Section {
                
                //TextField($enteredTime, label: Text("Enter Time:").font(.headline))
                Text("Time").font(.headline)
                TextField("1:23.45", value: $enteredTime, formatter: NumberFormatter())
               // Text("\(enteredTime)!")
                
            }
        }
    }
    
    var body: some View {
        return NavigationView {
            
            Form {
                section1
                
                section2
                
                
                section3
                
            }.navigationBarTitle(Text("Swim Time Converter"))
            
        }
    
        
    }
    
    
    
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
       
        ContentView(enteredTime: 0.0)
        
    }
}
