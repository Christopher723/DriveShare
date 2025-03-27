//
//  CarDetailView.swift
//  DriveShare
//
//  Created by Christopher Woods on 3/25/25.
//

import SwiftUI
import FirebaseFirestore



struct CarDetailView: View {
    var car: Car
    var isOwner = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Car Image Placeholder
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(16/9, contentMode: .fit)
                        .cornerRadius(12)
                    
                    Image(systemName: "car.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                }
                
                // Car Details
                VStack(alignment: .leading, spacing: 16) {
                    Text(car.CarModel)
                        .font(.largeTitle)
                        .bold()
                    
                    HStack {
                        PriceView(price: car.Pricing)
                        Spacer()
                        Text("Year: \(car.Year)")
                            .font(.headline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Divider()
                    
                    // Car Specs
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Vehicle Details")
                            .font(.title2)
                            .bold()
                        
                        DetailRow(icon: "speedometer", title: "Mileage", value: "\(car.Mileage) miles")
                        DetailRow(icon: "mappin.and.ellipse", title: "Pickup Location", value: "View on map")
                        
                        Text("Availability")
                            .font(.title3)
                            .bold()
                            .padding(.top, 8)
                        
                        Text("Green dates are available for booking. Red dates are unavailable.")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        // New Calendar View with flipped logic
                        AvailabilityCalendarView(unavailableDates: car.Availability)
                    }
                    
                    Divider()
                    
                    // Owner Actions
                    if isOwner {
                        OwnerActionsView(car: car)
                    } else {
                        RenterActionsView()
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Car Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 30, height: 30)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.body)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct PriceView: View {
    let price: Int
    
    var body: some View {
        Text("$\(price)/day")
            .font(.title2)
            .bold()
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(10)
    }
}
struct OwnerActionsView: View {
    let car: Car
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Owner Options")
                .font(.title3)
                .bold()
            
            NavigationLink(destination: EditCarView(car: car)) {
                HStack {
                    Image(systemName: "pencil")
                    Text("Edit Car Details")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            NavigationLink(destination: ManageAvailabilityView(car: car)) {
                HStack {
                    Image(systemName: "calendar")
                    Text("Manage Availability")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
}
struct ManageAvailabilityView: View {
    let car: Car
    @State private var selectedDates: [Date] = []
    @State private var showingDatePicker = false
    
    var body: some View {
        VStack {
            Text("Manage Unavailable Dates")
                .font(.headline)
                .padding(.top)
            
            Text("Mark dates when your car is NOT available for rental")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.bottom)
            
            // Display current availability with flipped logic
            AvailabilityCalendarView(unavailableDates: car.Availability)
            
            Button("Add New Unavailable Dates") {
                showingDatePicker = true
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding()
        }
        .navigationTitle("Block Dates")
        .sheet(isPresented: $showingDatePicker) {
            // This is a placeholder for a date picker sheet
            // You would implement a multi-date selection calendar here
            Text("Date Selection Sheet")
                .padding()
        }
    }
}


struct RenterActionsView: View {
    var body: some View {
        Button(action: {
            // Book the car
        }) {
            HStack {
                Image(systemName: "key.fill")
                Text("Book This Car")
                    .bold()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

// For preview purposes
#Preview {
        CarDetailView(
            car: Car(
                id: "123",
                CarModel: "Tesla Model 3",
                Availability: ["March 26, 2025", "March 27, 2025", "March 28, 2025"],
                Mileage: 15000,
                PickUpLocation: GeoPoint(latitude: 37.7749, longitude: -122.4194),
                Pricing: 85,
                Year: 2023,
                userId: "user123"
            ),
            isOwner: true
        )
}
