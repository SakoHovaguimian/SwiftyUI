//
//  ViewBuilderExample.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/29/23.
//

// TODO: -

/// [] Make a base builder ViewController for SwiftUI...
/// [] Make a navigationService that the base view controller conforms to
/// [] Make spacing service
/// [] Make background color of base view controller brand color background
/// [] Params: Title, Color, Content,
///
/// EXTENSIONS
/// // centerHorizontally
/// // center Vertically
/// Wrap the two above in HStack / VStack respectiviley

import SwiftUI

struct ViewBuilderExample<Content: View>: View {
    
    private var isLoading: Bool = false
    
    private let title: String
    private let content: Content
    
    init(title: String,
         isLoading: Bool = false,
         @ViewBuilder content: () -> Content) {
        
        self.title = title
        self.isLoading = isLoading
        self.content = content()
        
    }
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            AppColor.charcoal
                .opacity(0.5)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 16) {
                
                HStack(spacing: 8) {
                    
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .asButton {
                            print("Tapped image view")
                        }
                    
                    Image(systemName: "info.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .asButton {
                            print("Tapped image view")
                        }
                    
                    Text(self.title)
                        .font(.title)
                        .fontWeight(.heavy)
                        .fontDesign(.rounded)
                        .padding(.leading, 4)
                    
                    Spacer()
                    
                }
                .padding(.leading, 24)
                

                
                self.content
                    .overlay {
                        if self.isLoading {
                            
                            Spacer()
                            HStack {
                                Spacer()
                                CustomActivityIndicatorView()
                                Spacer()
                            }
                            Spacer()
                            
                        }
                    }
            }
        
        }
        
    }
    
}

struct TestActivityIndicatorView: View {
    
    @State private var isOn: Bool = false
    @State var isLoading: Bool = false
    
    var body: some View {
        
        ViewBuilderExample(
            title: "Home",
            isLoading: self.isLoading
        ) {
            
            //        CardView {
            //            VStack {
            //                Text("Testing")
            //                    .foregroundStyle(Color.green.gradient)
            //            }
            //        }
            
            List(content: {
                
                Section {
                    Text("Download files")
                        .listRowBackground(AppColor.charcoal.opacity(0.3))
                } header: {
                    
                    HStack(alignment: .center, spacing: 16) {
                        
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(8)
                            .background(Color.indigo.gradient)
                            .asButton {
                                print("Tapped image view")
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        Text("Download files")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.white)
                        
                    }
                    .padding(.vertical, 8)
                    .listRowInsets(.init(top: 24, leading: 0, bottom: 0, trailing: 0)) // THIS WORKS FOR HEADER
                    .listRowBackground(AppColor.charcoal.opacity(0.3))

                }
                
                Section("Shaun's Backend") {
                    
                    HStack(spacing: 16) {
                        
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(8)
                            .background(Color.indigo.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .asButton {
                                print("Tapped image view")
                            }
                        
                        Text("Download files")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        
                    }
                    
                    HStack(spacing: 16) {
                        
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(8)
                            .background(Color.teal.gradient)
                            .asButton {
                                print("Tapped image view")
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        Text("Download files")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        
                    }
                    
                    HStack(spacing: 16) {
                        
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(8)
                            .background(Color.green.gradient)
                            .asButton {
                                print("Tapped image view")
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        Text("Download files")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        
                    }
                    
                    HStack(spacing: 16) {
                        
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(8)
                            .background(Color.pink.gradient)
                            .asButton {
                                print("Tapped image view")
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        Text("Download files")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .resizable()
                            .frame(width: 8, height: 12)
                            .padding(8)
                        
                    }
                    
                    HStack(spacing: 16) {
                        
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(8)
                            .background(Color.orange.gradient)
                            .asButton {
                                print("Tapped image view")
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        Text("Download files")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        
                    }
                    
                    Toggle(isOn: self.$isOn, label: {
                        Text("API Down?")
                    })
                    
                    Toggle(isOn: self.$isOn, label: {
                        Text("API Down?")
                    })
                    
                    Toggle(isOn: self.$isOn, label: {
                        Text("API Down?")
                    })
                    
                }
                //            .listRowBackground(Color.green.opacity(0.2))
//                .listRowSpacing(20)
                .listRowBackground(AppColor.charcoal.opacity(0.3))
                .listRowSeparator(.hidden, edges: .all)
                
                Section("Sako's Frontend") {
                    
                    Button(action: {self.isLoading.toggle()}, label: {
                        Text("Click me")
                    })
                    .padding(.vertical, 8)
                    .buttonStyle(.borderedProminent)
                    
                    Toggle(isOn: self.$isOn, label: {
                        Text("API Down?")
                    })
                    
                    Toggle(isOn: self.$isOn, label: {
                        Text("API Down?")
                    })
                    
                }
                .listRowBackground(AppColor.charcoal.opacity(0.3))
                .listRowSeparator(.hidden, edges: .all)
                
            })
            .onTapGesture {
                self.isLoading.toggle()
            }
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden, edges: .all)
            .scrollContentBackground(.hidden) // HIDES BACKGROUND COLOR
            
//            .listStyle(.plain)
            
        }
        
    }
    
}

#Preview {
    TestActivityIndicatorView()
}


//                    Button(action: {}, label: {
//                        Text("Click me")
//                            .padding(8)
//                            .foregroundColor(.white)
//                            .font(.largeTitle)
//                            .background(Color.red)
//                            .clipShape(RoundedRectangle(cornerRadius: 3))
//                    })
//                    .padding(.vertical, 8)

struct CustomActivityIndicatorView: View {
    
    var body: some View {
        
        VStack {
            
            VStack(spacing: 24) {
                
                ProgressView()
                    .padding(.top, 8)
                    .scaleEffect(2)
                
                Text("Loading")
                    .font(.title)
                
            }
            
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 32)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        

    }
    
}
