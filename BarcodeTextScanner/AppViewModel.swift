//
//  AppViewModel.swift
//  BarcodeTextScanner
//
//  Created by Naman Vaishnav on 21/12/23.
//

import Foundation
import AVKit
import Foundation
import SwiftUI
import VisionKit

enum ScanType {
    case text, barcode
}

enum DataScannerAccessStatusType {
    case noDetermined
    case cameraAccessNotGranted
    case cameraNotAvailable
    case scannerAvailable
    case scannerNotAvailable
}

@MainActor
class AppViewModel: ObservableObject {
    
    @Published var dataScannerAccessStatus: DataScannerAccessStatusType = .noDetermined
    @Published var recognizedItems: [RecognizedItem] = []
    @Published var scanType: ScanType = .barcode
    @Published var textContentType : DataScannerViewController.TextContentType?
    @Published var recognizesMulitpleItems = true
    
    var recognizedDataType: DataScannerViewController.RecognizedDataType {
        scanType == .barcode ? .barcode() : .text(textContentType: textContentType)
    }
    
    private var isScannerAvailiable: Bool {
        DataScannerViewController.isAvailable && DataScannerViewController.isSupported
    }
    
    func requestDataScannerAccessStatus() async {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            dataScannerAccessStatus = .cameraNotAvailable
            return
        }
 
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            dataScannerAccessStatus = isScannerAvailiable ? .scannerAvailable : .scannerNotAvailable
        case .notDetermined, .denied:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if granted {
                dataScannerAccessStatus = isScannerAvailiable ? .scannerAvailable : .scannerNotAvailable
            } else {
                dataScannerAccessStatus = .cameraAccessNotGranted
            }
        case .restricted:
            dataScannerAccessStatus = .cameraNotAvailable
        
        @unknown default:
            break;
        }
    }
    
}