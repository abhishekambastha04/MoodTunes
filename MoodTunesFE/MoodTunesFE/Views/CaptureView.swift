//
//  CaptureView.swift
//  MoodTunesFE
//
//  Created by Abhishek Ambastha on 9/14/24.
//

import SwiftUI

struct CaptureView: View {
  @State private var showImagePicker = false
  @State private var pickerType: ImagePicker.PickerType?
  @State private var selectedImage: UIImage?
  @State private var isUploadButtonSelected = false
  @State private var isSelfieButtonSelected = false

  var body: some View {
    ZStack {
      Image("lightgreen")
        .resizable()
        .scaledToFill()
        .ignoresSafeArea()

      VStack {
        if let image = selectedImage {
          Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(width: 300, height: 300)
            .overlay(RoundedRectangle(cornerRadius: 10)
                      .stroke(Color("Black"), lineWidth: 4))
            .padding(10)
        } else {
          Text("No photo selected")
            .padding()
        }

        HStack {
          Button(action: {
            pickerType = .photoLibrary
            showImagePicker = true
            isUploadButtonSelected.toggle()
          }) {
           Text("Upload Photo")
              .foregroundColor(.white)
              .padding()
              .frame(width: 125, height: 100)
              .background(Color.darkGreen)
              .cornerRadius(10)
              .shadow(radius: isUploadButtonSelected ? 5 : 0)
              .scaleEffect(isUploadButtonSelected ? 1.1 : 1)
              .offset(y: isUploadButtonSelected ? -5 : 0)
          }

          Button(action: {
            pickerType = .camera
            isSelfieButtonSelected.toggle()
            showImagePicker = true
          }) {
          Text("Take Selfie")
              .foregroundColor(.white)
              .padding()
              .frame(width: 125, height: 100)
              .background(Color.darkGreen)
              .cornerRadius(10)
              .shadow(radius: isSelfieButtonSelected ? 5 : 0)
              .scaleEffect(isSelfieButtonSelected ? 1.1 : 1)
              .offset(y: isSelfieButtonSelected ? -5 : 0)
          }
          .padding()
        }

        Button(action: {
          proceedToNextStep()
        }) {
          Text("Next")
            .padding()
            .background(selectedImage == nil ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .disabled(selectedImage == nil) // Disable the button if no image is selected
      }
      .padding() // Adjust padding if needed
    }
    .sheet(isPresented: $showImagePicker) {
      if let pickerType = pickerType {
        ImagePicker(pickerType: pickerType, selectedImage: $selectedImage)
      }
    }
  }

  private func proceedToNextStep() {
    // Implement the action to proceed to the next step
    print("Proceeding to the next step with selected image.")
  }
}


extension Color {
    static let darkGreen = Color(red: 0.1, green: 0.5, blue: 0.2)
}
