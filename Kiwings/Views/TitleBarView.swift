//
//  TitleBarView.swift
//  Kiwings
//
//  Created by Maheep Kumar Kathuria on 18/11/22.
//

import SwiftUI
import LaunchAtLogin

struct TitleBarView: View {
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text("KiWings").font(.headline)
                if #available(macOS 12.0, *) {
                    Text("by ***[Maheep Kumar Kathuria](https://maheepk.net)***").font(.footnote)
                } else {
                    Text("by Maheep Kumar Kathuria").font(.footnote)
                }
            }.padding(.leading, 8)
            Spacer()
            MenuButton(
                label: Label("Settings", systemImage: "gearshape.fill").labelStyle(IconOnlyLabelStyle()),
                content: {
                    LaunchAtLogin.Toggle {
                        Text("Launch at login")
                    }
                    Button("Exit", action: {
                        NSRunningApplication.current.terminate()
                    })
                }
            ).menuButtonStyle(BorderlessPullDownMenuButtonStyle()).frame(width: 32, height: 32, alignment: .center).padding(.trailing, 8)
        }
    }
}

struct TitleBarView_Previews: PreviewProvider {
    static var previews: some View {
        TitleBarView()
    }
}
