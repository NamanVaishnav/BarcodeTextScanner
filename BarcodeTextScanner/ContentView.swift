//
//  ContentView.swift
//  BarcodeTextScanner
//
//  Created by Naman Vaishnav on 21/12/23.
//

import PhotosUI
import SwiftUI
import VisionKit

struct ContentView: View {
    
    @EnvironmentObject var vm: AppViewModel
    private let textContentType: [(title: String,textContentType: DataScannerViewController.TextContentType?)] = [
        ("All", .none),
        ("URL", .URL),
        ("Phone", .telephoneNumber),
        ("Email", .emailAddress),
        ("Address",.fullStreetAddress)
    ]
    
    
    var body: some View {
        switch vm.dataScannerAccessStatus {
        case .noDetermined:
            Text("Requesting camera access")
        case .cameraAccessNotGranted:
            Text("Please provide camera access from setting")
        case .cameraNotAvailable:
            Text("Your device don't have camera")
        case .scannerAvailable:
            mainView
        case .scannerNotAvailable:
            Text("Your device don't have support for scanning barcode with camera")
        }
    }
    
    private var mainView: some View {
        liveImageFeed
        .background {
            Color.gray.opacity(0.3)
        }
        .ignoresSafeArea()
        .id(vm.dataScannerViewId)
        .sheet(isPresented: .constant(true), content: {
            bottomContainerView
                .background(.ultraThinMaterial)
                .presentationDetents([.medium,.fraction(0.25)])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled()
                .disabled(vm.capturedPhoto != nil)
                .onAppear{
                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                          let controller = windowScene.windows.first?.rootViewController?.presentedViewController else {
                        return
                    }
                    controller.view.backgroundColor = .clear
                }
                .sheet(item: $vm.capturedPhoto) { photo in
                    ZStack(alignment: .topTrailing, content: {
                        Color.gray.ignoresSafeArea()
                        LiveTextView(image: photo.image)
                        Button {
                            vm.capturedPhoto = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .foregroundStyle(.white)
                                .padding()
                                .background(.ultraThinMaterial)
                        }
                        .edgesIgnoringSafeArea(.bottom)
                    })
                    
                }
        })
        .onChange(of: vm.scanType) { _ in vm.recognizedItems = [] }
        .onChange(of: vm.textContentType) { _ in vm.recognizedItems = [] }
        .onChange(of: vm.recognizesMulitpleItems) { _ in vm.recognizedItems = [] }
        .onChange(of: vm.selectedPhotoPickerItem) { newValue in
            guard let newValue = newValue else { return }
            Task { @MainActor in
                guard let data = try? await newValue.loadTransferable(type: Data.self),
                        let image = UIImage(data: data)
                else { return }
                self.vm.capturedPhoto = .init(image: image)
                
            }
        }
    }
    
    @ViewBuilder
    private var liveImageFeed: some View {
        if let capturedPhoto = vm.capturedPhoto {
            Image(uiImage: capturedPhoto.image)
                .resizable()
                .scaledToFit()
        } else {
            DataScannerView(
                shouldCapturePhoto: $vm.shouldCapturePhoto,
                capturedPhoto: $vm.capturedPhoto,
                recognizedItems: $vm.recognizedItems,
                recognizedDataType: vm.recognizedDataType,
                recognizedMultipleItems: vm.recognizesMulitpleItems)
        }
    }
    
    private var headerView: some View {
        VStack {
            HStack {
                Picker("Scan Type", selection: $vm.scanType) {
                    Text("Barcode").tag(ScanType.barcode)
                    Text("Text").tag(ScanType.text)
                }.pickerStyle(.segmented)
                
                Toggle("Scan Multiple", isOn: $vm.recognizesMulitpleItems)
                
            }
            .padding(.top)
            
            if vm.scanType == .text {
                Picker("Text content type", selection: $vm.textContentType){
                    ForEach(textContentType, id: \.self.textContentType){ option in
                        Text(option.title).tag(option.textContentType)
                    }
                }.pickerStyle(.segmented)
            }
            
            
            HStack {
                Text(vm.headerText)
                Spacer()
                PhotosPicker(selection: $vm.selectedPhotoPickerItem, matching: .images) {
                    Image(systemName: "photo.circle")
                        .imageScale(.large)
                        .font(.system(size: 32))
                }
                Button(action: {
                    vm.shouldCapturePhoto = true
                }, label: {
                    Image(systemName: "camera.circle")
                        .imageScale(.large)
                        .font(.system(size: 32))
                })
            }
            
            
        }
        .padding(.horizontal)
    }
    
    private var bottomContainerView: some View {
        VStack{
            headerView
            ScrollView {
                LazyVStack(alignment: .leading , spacing: 16, content: {
                    ForEach(vm.recognizedItems) { item in
                        switch item {
                        case .barcode(let barcode):
                            Text(barcode.payloadStringValue ?? "Unknown barcode")
                        case .text(let text):
                            Text(text.transcript)
                        @unknown default:
                            Text("Unnknown")
                            
                        }
                    }
                })
                .padding()
            }
        }
    }
}

//#Preview {
//    ContentView()
//}
