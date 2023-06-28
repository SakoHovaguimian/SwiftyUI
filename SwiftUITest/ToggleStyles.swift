//
//  ToggleStyles.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/27/23.
//

import SwiftUI

extension ToggleStyle where Self == SettingsToggleStyle {
  static var settings: SettingsToggleStyle {
    SettingsToggleStyle()
  }
}

struct SettingsToggleStyle: ToggleStyle {
  private let onStyle: AnyShapeStyle = AnyShapeStyle(.tint)
  private let offStyle: AnyShapeStyle = AnyShapeStyle(.gray)

  func makeBody(configuration: Configuration) -> some View {
    HStack {
      configuration.label
      Spacer()
      Image(systemName: configuration.isOn ? "square.fill"
                                           : "square")
        .resizable()
        .frame(width: 24, height: 24)
        .foregroundStyle(configuration.isOn ? onStyle : offStyle)
        .onTapGesture {
          configuration.isOn.toggle()
        }
    }
  }
}

extension ToggleStyle where Self == ReminderToggleStyle {
  static var reminder: ReminderToggleStyle {
    ReminderToggleStyle()
  }
}

struct ReminderToggleStyle: ToggleStyle {
  private let onStyle: AnyShapeStyle = AnyShapeStyle(.tint)
  private let offStyle: AnyShapeStyle = AnyShapeStyle(.gray)

  func makeBody(configuration: Configuration) -> some View {
    HStack {
      configuration.label
      Image(systemName: configuration.isOn ? "largecircle.fill.circle"
                                           : "circle")
        .resizable()
        .frame(width: 24, height: 24)
        .foregroundStyle(configuration.isOn ? onStyle : offStyle)
        .onTapGesture {
          configuration.isOn.toggle()
        }
    }
  }
}

struct SettingsView: View {
    
  @State var sync = true
  @State var detectDates = false
  @State var sendReminders = false
    
  var body: some View {
      
      ZStack {
          
          Form {
              
              Section {
                  
                  Toggle(isOn: $sync) {
                    Text("Sync tasks in real-time")
                  }
                    
                  Toggle(isOn: $detectDates) {
                    Text("Detect due dates in tasks automatically")
                  }
                    
                  Toggle(isOn: $sendReminders) {
                    Text("Send daily reminder")
                  }
                  
              }
              .toggleStyle(.settings)
              
              Section {
                  
                  Toggle(isOn: $sync) {
                      HStack {
                          Text("Sync tasks in real time")
                          Spacer()
                      }
                  }
                    
                  Toggle(isOn: $detectDates) {
                      HStack {
                          Text("Detect due dates in tasks automatically")
                          Spacer()
                      }
                  }
                    
                  Toggle(isOn: $sendReminders) {
                      HStack {
                          Text("Send daily reminder")
                          Spacer()
                      }
                  }
                  
                  Toggle(isOn: $sync) {
                      Text("Have you tried turning it \(self.sync ? "off" : "on")?")
                  }
                  .toggleStyle(.button)
                  .tint(self.sync ? .pink : Color(uiColor: .gray))
                  
              }
              .toggleStyle(.reminder)
              
          }
          .tint(.pink)
          
          Spacer()
          HStack(content: {
              
              Button(action: {}, label: {
                  Text("Add new Reminder")
              })
              .tint(Color.pink)
              .buttonStyle(.borderedProminent)
              
              Spacer()
              
          })
          .frame(maxHeight: .infinity, alignment: .bottomLeading)
          .padding(.leading, 32)
          
      }
    .navigationTitle("Settings")
      
  }
    
}

#Preview {
    SettingsView()
}
