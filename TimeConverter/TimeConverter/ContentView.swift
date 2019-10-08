//
//  ContentView.swift
//  NewTimeConverter
//
//  Created by Yvette Zhukovsky on 9/22/19.
//  Copyright © 2019 bumnetworks. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    @EnvironmentObject var settings: Settings
  //  @State var sc: SavingConversions
    @State private var fromCourse: Course = Course.SCY(._50)
    @State var userEntered: String = ""
    @State private var toCourse: Course = Course.SCY(._50)
    
    
    private let availableCourses: [Course] =
        Yards.allCases.map{Course.SCY($0.id)} +
            Meters.allCases.map{Course.LCM($0.id)} +
            Meters.allCases.map{Course.SCM($0.id)}
    
    func renderCourse(_ c: Course) -> some View {
        Text("\(c.format())").tag(c)
        
    }
    func coursePicker(_ selection: Binding<Course>, _ label: Text?, _ courses: [Course]) -> some View {
        Picker(selection: selection, label: label) {
            ForEach(courses) { dis in
                self.renderCourse(dis.id)
                
            }
        }
    }
    var section1: some View {
        Section {
            Text("From course").font(.headline)
            coursePicker($fromCourse, _:nil , availableCourses).labelsHidden()
            
        }
    }

    var section2: some View {
        Section {
            Section {
                
                //TextField($enteredTime, label: Text("Enter Time:").font(.headline))
                Text("Time").font(.headline)
                TextField("1:23.04", text: $userEntered)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
            }
        }
    }
    
    func parseTime(enteredTime: String)-> Double? {
        
        let parts = enteredTime.components(separatedBy: ":")
        if parts.count == 1 {
            return Double(enteredTime)
            
        } else {
            let minutes = Int(parts.first ?? "") ?? 0
            let rest = Double(enteredTime.components(separatedBy: ":")[1]) ?? 0.0
            
            return (Double((minutes * 60)) + rest)
        }
    }
    
    
    func formatTime(time:Double)-> String {
        let minutes = Int(time) / 60
        let seconds = Double(Int(time) % 60) + time - Double(Int(time))
        
        return "\(minutes):\(NSString(format: "%2.3f", seconds))"
        
    }
    
    func getConversion() -> ((Double, Course, Course) -> Double)? {
        Conversions.ShortCourseYardsToMeters.possibleConversions(fromCourse).first{
            $0.0 == toCourse
            }?.1
    }
    
    func performConversion()-> some View {
        guard let f = getConversion() else {return Text("")}
        let enteredData = parseTime(enteredTime: userEntered)
        
       // settings.savedCourse?.conversions.
        guard let t = enteredData else {return Text("")}
        let beforeFormat = f(t, fromCourse, toCourse)
        let afterFormat = formatTime(time: beforeFormat)
        let sc = SavedConversion(from: fromCourse, to: toCourse, timeEntered: userEntered, timeConverted: afterFormat)
        settings.savedCourse?.conversions.append(sc)
        return Text("\(afterFormat)")
        
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
        
        List  {
            Section {
                VStack{
                Text("Result").font(.headline)
                performConversion()
                    
                    .shadow(color: .black, radius: 1, x: 0, y: 1)
            }
        }
        }
        .listRowInsets(EdgeInsets())
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue, lineWidth: 4))

    }

    var body: some View {
        return NavigationView {
            Form {
                section1
                section2
                section3
                section4
               NavigationLink(destination: SavedConversions()) {
                Text("Saved Conversions")
                }
            }
            .navigationBarTitle(Text("Swim Time Converter"))
            
        }
        
    }
    
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        ContentView()
        
    }
}
