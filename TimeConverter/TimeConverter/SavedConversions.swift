//
//  SavedConversions.swift
//  TimeConverter
//
//  Created by Yvette Zhukovsky on 10/4/19.
//  Copyright © 2019 bumnetworks. All rights reserved.
//

import SwiftUI
import Combine



struct SavedConversions: View {
    @EnvironmentObject var settings: Settings
    
    var body: some View {
       
        let xs: [History] = settings.savedCourse?.conversions ?? []
       return NavigationView {
        List {
            ForEach(xs, id: \.id) { x in
               
                VStack(alignment: .leading) {
                     if x.timeConverted != "" {
                    Image(systemName: "stopwatch").foregroundColor(.purple)
                    Text("\(x.fromCourse.format())").tag(x)
                    Text("\(x.toCourse.format())").tag(x)
                    Text("Entered: \(x.timeEntered) Converted:\((x.timeConverted))")
                    
                    }
                }
            }
            .onDelete(perform: delete)
            }.navigationBarItems(leading: EditButton())
        }
    }
    
    
    func renderCourse(_ c: Event) -> some View {
        Text("\(c.format())").tag(c)
    }
    
    func delete(at offsets: IndexSet) {
        guard let index = Array(offsets).first else { return }
        var scs = settings.savedCourse ?? SavingHistory(conversions: [])
         scs.conversions.remove(at: index)
        //print(scs.conversions.remove(at: index))
        settings.savedCourse = scs
       
    }
}

struct SavedConversions_Previews: PreviewProvider {
    static var previews: some View {
        SavedConversions()
    }
}
