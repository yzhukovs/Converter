//
//  ContentView.swift
//  NewTimeConverter
//
//  Created by Yvette Zhukovsky on 9/22/19.
//  Copyright © 2019 bumnetworks. All rights reserved.
//

import SwiftUI
import UIKit

struct ContentView : View {
    @EnvironmentObject var settings: Settings
  //  @State var sc: SavingConversions
    @State private var fromCourse: Event = Event.SCY(._50)
    @State private var userEntered: String = ""
    @State private var toCourse: Event = Event.SCY(._50)
    
    
    private let availableCourses: [Event] =
        Yards.allCases.map{Event.SCY($0.id)} +
            Meters.allCases.map{Event.LCM($0.id)} +
            Meters.allCases.map{Event.SCM($0.id)}
    
    func renderCourse(_ c: Event) -> some View {
        Text("\(c.format())").tag(c)
        
    }
    func coursePicker(_ selection: Binding<Event>, _ label: Text?, _ courses: [Event]) -> some View {
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
                 SATextField(tag: 0, placeholder: "1:23.04", changeHandler: { (newString) in
                               self.userEntered = WrappableTextField.formattedNumber(newString)
                           }
                    , onCommitHandler: {
                        self.persistance(input: self.userEntered)
                        
                 })
            }
            
        }
        .keyboardType(.numberPad)
        .textContentType(.oneTimeCode)
        .textFieldStyle(RoundedBorderTextFieldStyle())
    }
    
    func parseTime(enteredTime: String)-> Double? {
        print(enteredTime)
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
        if time  == 0 {
            return ""
        }
        let minutes = Int(time) / 60
        let seconds = Double(Int(time) % 60) + time - Double(Int(time))
        
        return "\(minutes):\(NSString(format: "%2.2f", seconds))"
        
    }
    
    func getConversion() -> ((Double, Event, Event) -> Double)? {
        Conversions.ShortCourseYardsToMeters.possibleConversions(fromCourse).first{
            $0.0 == toCourse
            }?.1
    }
    
   func persistance(input: String){
        let sc = History(id: UUID() , fromCourse: fromCourse, toCourse: toCourse, timeEntered: userEntered, timeConverted: input)
        var scs = settings.savedCourse ?? SavingHistory(conversions: [])
        scs = SavingHistory(conversions: scs.conversions + [sc])
        settings.savedCourse = scs
        
    }
    
    func performConversion()-> some View {
        guard let f = getConversion() else {return Text("")}
        let enteredData = parseTime(enteredTime: userEntered)
        guard let t = enteredData else {return Text("")}
        let beforeFormat = f(t, fromCourse, toCourse)
        print(t)
        let afterFormat = formatTime(time: beforeFormat)
       //persistance(input: afterFormat)
        return Text("\(afterFormat)")
        
    }

    var section3: some View {
        Section {
            Section(header: Text("To course") ) {
               // Text("To course").font(.headline)
                coursePicker($toCourse, Text("Select"), Conversions.ShortCourseYardsToMeters.possibleConversions(fromCourse).map{$0.0})//.labelsHidden()
                
            }
            }
            .padding(.trailing)
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
        NavigationView {
            Form {
                section1
                section2
                section3
                section4
                NavigationLink(destination: SavedConversions().environmentObject(settings)) {
                Text("Saved Conversions")
                }
            }
            .navigationBarTitle(Text("Swim Time Converter"))
            
        }
        
    }
    
}



class WrappableTextField: UITextField, UITextFieldDelegate {
    var contentView = ContentView()
    var textFieldChangedHandler: ((String)->Void)?
    var onCommitHandler: (()->Void)?
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
            addDoneButtonOnKeyboard()
            self.returnKeyType = .done
            self.keyboardType = .numberPad
        } else {
            textField.resignFirstResponder()
            addDoneButtonOnKeyboard()
            self.returnKeyType = .done
        }
        return false
    }
    
    static func formattedNumber(_ str: String) -> String {
        let numbers = Set("0123456789")
        let stripped = str.filter { numbers.contains($0) }

        guard let number = Int(stripped) else { return "" }
        let mili = number % 100
        let seconds = number % 10000 / 100
        let minutes = number % 1000000 / 10000
        var formatted: String = ""

        if str.count > 4 {
            formatted = "\(String(format: "%02i", minutes)):\(String(format: "%02i", seconds)).\(String(format: "%02i", mili))"
        } else {
            formatted = "\(String(format: "%02i", seconds)).\(String(format: "%02i", mili))"
        }
        return formatted
    }

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.rightViewMode = .always
        self.keyboardType = .numberPad
        textField.clearButtonMode = .always
       guard let currentValue = textField.text else {
            return true
        }
        
        if let currentValue = textField.text as NSString? {
            let proposedValue = currentValue.replacingCharacters(in: range, with: string)
            textFieldChangedHandler?(proposedValue as String)
        }
        
        let newString = (currentValue as NSString).replacingCharacters(in: range, with: string)
        textField.text = WrappableTextField.formattedNumber(newString)
       
        return false
        
    }
        func addDoneButtonOnKeyboard() {
            let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
            doneToolbar.barStyle       = UIBarStyle.default
         let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
            
            var items = [UIBarButtonItem]()
            items.append(flexSpace)
            items.append(done)

            doneToolbar.items = items
            doneToolbar.sizeToFit()

            self.inputAccessoryView = doneToolbar
        }
        @objc func doneButtonAction() {
            self.returnKeyType = .done
            if let och = self.onCommitHandler {
                och()
            }
            self.resignFirstResponder()
        }
       
        
        
  
}

struct SATextField: UIViewRepresentable {
    private let tmpView = WrappableTextField()
    
    var tag:Int = 0
    var placeholder:String?
    var changeHandler:((String)->Void)?
    var onCommitHandler:(()->Void)?
    
    func makeUIView(context: UIViewRepresentableContext<SATextField>) -> WrappableTextField {
       
        tmpView.tag = tag
        tmpView.delegate = tmpView
        tmpView.placeholder = placeholder
        tmpView.onCommitHandler = onCommitHandler
        tmpView.textFieldChangedHandler = changeHandler
        tmpView.keyboardType = .numberPad
        return tmpView
    }
    
    func updateUIView(_ uiView: WrappableTextField, context: UIViewRepresentableContext<SATextField>) {
         uiView.addDoneButtonOnKeyboard()
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        ContentView()
        
    }
}
