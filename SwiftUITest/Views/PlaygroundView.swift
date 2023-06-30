//
//  MarkdownView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/19/23.
//

import SwiftUI

struct PlaygroundView: View {
    
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var signupError: String? = nil
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            LinearGradient(
                colors: [AppColor.charcoal, AppColor.eggShell],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
//                Spacer()
                
                //            Text("`Welcome` to the **Jungle**")
                //            Text(Date(), style: .date)
                //            Text(Date(), style: .offset)
                //            Text(Date(), style: .relative)
                //            Text(Date(), style: .time)
                //            Text(Date(), style: .timer)
                //
                //            Text(Date().formatted(
                //
                //                .dateTime.day(.defaultDigits)
                //                .month(.defaultDigits)
                //                .year(.defaultDigits)
                //
                //
                //            ) + " and \(Date().formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.defaultDigits))) is the time")
                //
                //            let double: Double = 2.23456.round(to: 2)
                //            let double1: Double = 2.23456.round(to: 4)
                //            let truncate: Double = 1.234567.truncate(to: 2)
                //
                //            let _ = print(double)
                //            let _ = print(double1)
                //            let _ = print(truncate)
                //
                //
                //            Text("\(double, specifier: "%.3f")")
                //            Text("\(double1, specifier: "%.5f")")
                //            Text("\(truncate, specifier: "%.2f")")
                
                VStack(spacing: 16) {
                    
                    HStack {
                        Image(systemName: "person.fill")
                        TextField("Name...", text: $name)
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                    .shadow(radius: 2, y: 4)
                    
                    HStack {
                        Image(systemName: "calendar")
                        TextField("Age......", text: $age)
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                    .shadow(radius: 10)
                    .keyboardType(.numberPad)
                    
                    VStack(spacing: 0) {
                        
                        HStack {
                            Image(systemName: "calendar")
                            TextField("Age......", text: $age)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
//                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                        .shadow(radius: 10)
                        .keyboardType(.numberPad)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.6))
                            .padding(.horizontal, 8)
                            .cornerRadius(8)
                            .frame(height: 2)
                        
                    }
                    


                    
                    if let signupError {
                        
                        VStack(alignment: .leading) {
                            
    //                        Spacer()
                            
                            Text(signupError)
                                .foregroundColor(.red.opacity(0.7))
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 8)
                            
    //                        Spacer()
                            
                        }
                        
                    }
                    
                }
                .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height / 3)
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .foregroundColor(.white)
                .background(.white.opacity(1))
                .clipShape(RoundedRectangle(cornerRadius: 11))
                .shadow(radius: 23)
                .overlay(alignment: .top) {
                    
                    ZStack {
                     
                        Circle().fill(AppColor.eggShell).frame(width: 64, height: 64)
                            .offset(y: -32)
                            .shadow(radius: 11, y: 2)
                        
                        Circle().stroke(Color.white, lineWidth: 4).frame(width: 64, height: 64)
                            .offset(y: -32)
                            .shadow(radius: 11, y: 2)
                        
                    }
                }
                
//                Spacer()
                
                
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 100)
//            .background(AppColor.eggShell.opacity(0.7))
//            .cornerRadius(11)
            
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//            .shadow(radius: 23)
//            .padding(.horizontal, 32)
            //            .padding(.vertical, 64)
            //            .padding(.horizontal, 32)
            .onChange(of: self.age) { newValue in
                withAnimation(.spring()) {
                    signupError = nil
                }
            }
            .onChange(of: self.name) { newValue in
                withAnimation(.spring()) {
                    signupError = nil
                }
            }
            
            VStack {
                
                Spacer()
                
                Button {
                    handleSubmit()
                } label: {
                    
                    Text("Submit")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)

                }
                .frame(width: UIScreen.main.bounds.width - 64, height: 50)
                .font(.callout)
                .background(Color.blue.gradient.opacity(1))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
            }
            .padding(.bottom, 8)
//            .frame(maxWidth: .infinity, maxHeight: .infinity)

        }
        .hideKeyboard()
        
    }
    
    private func handleSubmit() {
    
        if self.age.isEmpty || self.name.isEmpty {
            withAnimation(.spring()) {
                self.signupError = "one or more fields are not filled out"
            }
        }
        else {
            print("Submitted : age \(self.age), name: \(self.name)")
        }
        
    }
    
}

struct MarkdownView_Previews: PreviewProvider {
    static var previews: some View {
        PlaygroundView()
    }
}

extension Double {
    
    func round(to places: Int) -> Double {
        
        let multiplier = Int(pow(10, Double(places)))
        return (self * Double(multiplier)).rounded() / Double(multiplier)
        
    }

    func truncate(to places: Int) -> Double {
        
        let multiplier = Int(pow(10, Double(places)))
        return Double(Int(self * Double(multiplier))) / Double(multiplier)
        
    }
    
}
