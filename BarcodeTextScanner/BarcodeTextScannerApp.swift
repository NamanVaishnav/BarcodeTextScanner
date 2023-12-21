//
//  BarcodeTextScannerApp.swift
//  BarcodeTextScanner
//
//  Created by Naman Vaishnav on 21/12/23.
//

import SwiftUI

@main
struct BarcodeTextScannerApp: App {
    @StateObject private var vm = AppViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
                .task {
                    await vm.requestDataScannerAccessStatus()
                }
        }
    }
}
