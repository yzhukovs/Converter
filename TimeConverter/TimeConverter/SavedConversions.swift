//
//  SavedConversions.swift
//  TimeConverter
//
//  Created by Yvette Zhukovsky on 10/4/19.
//  Copyright © 2019 bumnetworks. All rights reserved.
//

import SwiftUI
import Combine

//struct SavedConversionRow: View {
// var history: History
//    @EnvironmentObject var settings: Settings
//
//    var body: some View {
//        ForEach(settings.savedCourse?.conversions ?? [], id: \.self) { event in
//            Text(String(event))
//        }
//       // guard let sc = settings.savedCourse else { return Text("") }
//       // Text("Converted: \(settings.savedCourse?.conversions[]))")
//    }
//}


struct SavedConversions: View {
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        // guard let scc = settings.savedCourse else { return List( content: Text(""))}
        let xs: [History] = settings.savedCourse?.conversions ?? []
        return List {
            ForEach(xs, id: \.self) { x in
                HStack {
                    Text("\(x.fromCourse.format())" ).tag(x)
                   Text("\(x.toCourse.format())").tag(x)

                }
            }
        }
    }
    func renderCourse(_ c: Event) -> some View {
        Text("\(c.format())").tag(c)
        
    }
    
    //    func coursePicker(_ selection: Binding<[Event]>, _ label: Text?) -> some View {
    //    Picker(selection: selection, label: label) {
    //        ForEach(courses) { dis in
    //            self.renderCourse(dis.id)
    //
    //        }
    //    }
    //    }
}

struct SavedConversions_Previews: PreviewProvider {
    static var previews: some View {
        SavedConversions()
    }
}
