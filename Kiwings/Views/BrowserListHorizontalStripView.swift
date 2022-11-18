//
//  BrowserListHorizontalStripView.swift
//  Kiwings
//
//  Created by Maheep Kumar Kathuria on 18/11/22.
//

import SwiftUI

struct BrowserListHorizontalStripView: View {
    var appURLs: [URL] = {
        // Solved using the approach mentioned in this answer: https://stackoverflow.com/a/931277/4385319
        let appBundleIdsForURLScheme: [String] = (LSCopyAllHandlersForURLScheme("https" as CFString)?.takeRetainedValue() as? [String])?.compactMap { $0 } ?? []
        let appBundleIdsForFileType: Set<String> = Set((LSCopyAllRoleHandlersForContentType("public.html" as CFString, .viewer)?.takeRetainedValue() as? [String])?.compactMap { $0 } ?? [])
        let installedBrowserIds: [String] = appBundleIdsForURLScheme.filter { bundleId in
            appBundleIdsForFileType.contains(bundleId)
        }
        return installedBrowserIds.compactMap { bundleId in
            NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId)
        }
    }()
    
    @Binding var port: Int
    
    var body: some View {
        VStack {
            ForEach(appURLs.chunked(into: 7), id: \.self) { appURLChunk in
                HStack {
                    ForEach(appURLChunk, id: \.self) { appURL in
                        Button(action: {
                            NSWorkspace.shared.open([URL(string: "http://localhost:\(self.port)")!], withApplicationAt: appURL, configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
                        }, label: {
                            Image(nsImage: NSWorkspace.shared.icon(forFile: Bundle(url: appURL)?.bundlePath ?? "")).resizable().frame(width: 32, height: 32, alignment: .center)
                        })
                        .buttonStyle(PlainButtonStyle())
                        .shadow(radius: 1.1)
                    }
                }
            }
        }
    }
}

struct BrowserListHorizontalStripView_Previews: PreviewProvider {
    static var previews: some View {
        BrowserListHorizontalStripView(port: .constant(8080))
    }
}
