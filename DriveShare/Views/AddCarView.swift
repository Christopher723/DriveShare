//
//  AddCarView.swift
//  DriveShare
//
//  Created by Christopher Woods on 4/17/25.
//

import SwiftUI
import FirebaseFirestore

struct AddCarView: View {
    @EnvironmentObject var firestoreManager: FirestoreManager
//    @EnvironmentObject private var viewModel: SignInEmaiLViewModel
    @State var CarModel: String = ""
    @State var Availability: [String] = [""]
    @State var Mileage: Int = 0
    @State var PickUpLocation: GeoPoint = GeoPoint(latitude: 0, longitude: 0)
    @State var Pricing: Int = 0
    @State var Year:  Int = 0
    
    let currentUser = try? AuthenticationManager.shared.getAuthUser().email ?? "No User"
    
    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.zeroSymbol = ""
        return formatter
    }
    
    @State var newAvailability: String = ""
    
    var body: some View {VStack {
        
        TextField("Car Model", text: $CarModel)
            .padding()
        
        TextField("Availability", text: $newAvailability)
            .padding()
        
        TextField("Mileage", value: $Mileage, formatter: numberFormatter)
            .keyboardType(.numberPad)
            .padding()
        
        TextField("Pick Up Location", text: Binding(
            get: { "\(PickUpLocation.latitude), \(PickUpLocation.longitude)" },
            set: { newValue in
                let parts = newValue.split(separator: ",")
                if parts.count == 2,
                   let lat = Double(parts[0].trimmingCharacters(in: .whitespaces)),
                   let lon = Double(parts[1].trimmingCharacters(in: .whitespaces)) {
                    self.PickUpLocation = GeoPoint(latitude: lat, longitude: lon)
                }
            }
        ))
        .padding()
        
        TextField("Pricing", value: $Pricing, formatter: numberFormatter)
            .keyboardType(.numberPad)
            .padding()
        
        TextField("Year", value: $Year, formatter: numberFormatter)
            .keyboardType(.numberPad)
            .padding()
        
        Button(action: {
            Availability.append(newAvailability)
            firestoreManager.addCar(
                CarModel: CarModel,
                Availability: Availability,
                Mileage: Mileage,
                PickUpLocation: PickUpLocation,
                Pricing: Pricing,
                Year: Year,
                userId: currentUser ?? "noEmail")
        },
               label: {
            Text("Add Car")
        })
    }
    .padding()
    }
}
extension Formatter {
    static let lucNumberFormat: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minusSign   = "👺 "  // Just for fun!
        formatter.zeroSymbol  = ""     // Show empty string instead of zero
        return formatter
    }()
}

#Preview {
    AddCarView(
        firestoreManager: EnvironmentObject()
    )
}
