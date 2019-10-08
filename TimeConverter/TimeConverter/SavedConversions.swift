//
//  SavedConversions.swift
//  TimeConverter
//
//  Created by Yvette Zhukovsky on 10/4/19.
//  Copyright © 2019 bumnetworks. All rights reserved.
//

import SwiftUI

struct SavedConversionRow: View {
    var sc: SavedConversion

    var body: some View {
        Text("Come and eat at \(String(sc.timeConverted))")
    }
}


struct SavedConversions: View {
    @EnvironmentObject var settings: Settings
    
    var body: some View {
       // guard let scc = settings.savedCourse else { return List( content: Text(""))}
        return List(settings.savedCourse?.conversions ?? [], rowContent: SavedConversionRow.init)
   }
}

struct SavedConversions_Previews: PreviewProvider {
    static var previews: some View {
        SavedConversions()
    }
}
