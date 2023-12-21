//
//  ContentView.swift
//  BarcodeTextScanner
//
//  Created by Naman Vaishnav on 21/12/23.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var vm: AppViewModel 
    var body: some View {
        switch vm.dataScannerAccessStatus {
        case .noDetermined:
            Text("Requesting camera access")
        case .cameraAccessNotGranted:
            Text("Please provide camera access from setting")
        case .cameraNotAvailable:
            Text("Your device don't have camera")
        case .scannerAvailable:
            Text("Scanner is Available")
        case .scannerNotAvailable:
            Text("Your device don't have support for scanning barcode with camera")
        }
    }
    
    private var mainView: some View {
        DataScannerView(
            recognizedItems: $vm.recognizedItems,
            recognizedDataType: vm.recognizedDataType,
            recognizedMultipleItems: vm.recognizesMulitpleItems)
    }
}

//#Preview {
//    ContentView()
//}
