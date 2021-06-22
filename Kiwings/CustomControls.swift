//
//  CustomControls.swift
//  Kiwings
//
//  Created by Maheep Kumar Kathuria on 21/06/21.
//

import SwiftUI

struct CheckmarkToggleStyle: ToggleStyle {
    var scaleFactor: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Rectangle()
                .foregroundColor(configuration.isOn ? .green : .gray)
                .frame(width: 51*scaleFactor, height: 31*scaleFactor, alignment: .center)
                .overlay(
                    Circle()
                        .foregroundColor(.white)
                        .padding(.all, 3*scaleFactor)
                        .overlay(
                            Image(systemName: configuration.isOn ? "checkmark" : "xmark")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .font(Font.title.weight(.black))
                                .frame(width: 8*scaleFactor, height: 8*scaleFactor, alignment: .center)
                                .foregroundColor(configuration.isOn ? .green : .gray)
                        )
                        .offset(x: configuration.isOn ? 11*scaleFactor : -11*scaleFactor, y: 0)
                        .animation(Animation.linear(duration: 0.1))
                        
                ).cornerRadius(20*scaleFactor)
                .padding(EdgeInsets(top: 2, leading: 0, bottom: 0, trailing: 0))
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
    }
}

struct StepperField: View {
    var placeholderText: String
    var value: Binding<Int>
    var minValue: Int?
    var maxValue: Int?
    var body: some View {
        ZStack {
            let binding = Binding<Int>(
                get: { self.value.wrappedValue },
                set: { self.value.wrappedValue = $0 }
            )
            TextField(placeholderText, value: binding, formatter: NumberFormatter()).textFieldStyle(RoundedBorderTextFieldStyle())
                .multilineTextAlignment(.center)
            HStack(alignment: .center) {
                Button(action: {
                    self.value.wrappedValue -= 1
                    if let minimumVal = minValue {
                        self.value.wrappedValue = max(minimumVal, self.value.wrappedValue)
                    }
                }, label: {
                    Text("−").bold()
                }).buttonStyle(PlainButtonStyle()).frame(width: 16, height: 16, alignment: .center)
                Spacer()
                Button(action: {
                    self.value.wrappedValue += 1
                    if let maxVal = maxValue {
                        self.value.wrappedValue = min(maxVal, self.value.wrappedValue)
                    }
                }, label: {
                    Text("+").bold()
                }).buttonStyle(PlainButtonStyle()).frame(width: 16, height: 16, alignment: .center)
            }
        }
    }
}
