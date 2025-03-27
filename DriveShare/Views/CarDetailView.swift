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

import SwiftUI
import FirebaseFirestore

// First, let's modify the RenterActionsView to show our payment sheet
struct RenterActionsView: View {
    @State private var showingPaymentSheet = false
    @State private var selectedStartDate = Date()
    @State private var selectedEndDate = Date().addingTimeInterval(86400) // Next day by default
    
    var body: some View {
        VStack(spacing: 16) {
            // Date selection
            HStack {
                VStack(alignment: .leading) {
                    Text("Start Date")
                        .font(.caption)
                        .foregroundColor(.gray)
                    DatePicker("", selection: $selectedStartDate, displayedComponents: .date)
                        .labelsHidden()
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("End Date")
                        .font(.caption)
                        .foregroundColor(.gray)
                    DatePicker("", selection: $selectedEndDate, in: selectedStartDate..., displayedComponents: .date)
                        .labelsHidden()
                }
            }
            
            Button(action: {
                showingPaymentSheet = true
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
        .sheet(isPresented: $showingPaymentSheet) {
            PaymentView(
                startDate: selectedStartDate,
                endDate: selectedEndDate,
                onComplete: {
                    showingPaymentSheet = false
                    // Here you would update the booking in Firestore
                }
            )
        }
    }
}

// Now let's create our PaymentView
struct PaymentView: View {
    let startDate: Date
    let endDate: Date
    let onComplete: () -> Void
    
    @State private var cardNumber = ""
    @State private var cardholderName = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var isProcessing = false
    @State private var bookingComplete = false
    @Environment(\.dismiss) private var dismiss
    
    // Calculate number of days for the booking
    var numberOfDays: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return max(components.day ?? 1, 1) // Ensure at least 1 day
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Booking summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Booking Summary")
                            .font(.headline)
                        
                        HStack {
                            Text("Start Date:")
                            Spacer()
                            Text(startDate, style: .date)
                                .bold()
                        }
                        
                        HStack {
                            Text("End Date:")
                            Spacer()
                            Text(endDate, style: .date)
                                .bold()
                        }
                        
                        HStack {
                            Text("Duration:")
                            Spacer()
                            Text("\(numberOfDays) day\(numberOfDays > 1 ? "s" : "")")
                                .bold()
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total:")
                            Spacer()
                            Text("$\(85 * numberOfDays)")  // Using a fixed price of $85 from the preview
                                .font(.title3)
                                .bold()
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Payment details
                    if !bookingComplete {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Payment Information")
                                .font(.headline)
                            
                            VStack(alignment: .leading) {
                                Text("Card Number")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                TextField("4242 4242 4242 4242", text: $cardNumber)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Cardholder Name")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                TextField("John Doe", text: $cardholderName)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            HStack(spacing: 20) {
                                VStack(alignment: .leading) {
                                    Text("Expiry Date")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    TextField("MM/YY", text: $expiryDate)
                                        .keyboardType(.numberPad)
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("CVV")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    TextField("123", text: $cvv)
                                        .keyboardType(.numberPad)
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                            
                            Button(action: processPayment) {
                                if isProcessing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Complete Booking")
                                        .bold()
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isProcessing ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .disabled(isProcessing)
                        }
                    } else {
                        // Booking confirmation
                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.green)
                            
                            Text("Booking Confirmed!")
                                .font(.title)
                                .bold()
                            
                            Text("Your car is reserved from \(startDate, style: .date) to \(endDate, style: .date)")
                                .multilineTextAlignment(.center)
                            
                            Text("Booking Reference: \(generateBookingReference())")
                                .font(.headline)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            
                            Button("Done") {
                                dismiss()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Complete Booking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !bookingComplete {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    private func processPayment() {
        // Validate input
        guard !cardNumber.isEmpty, !cardholderName.isEmpty,
              !expiryDate.isEmpty, !cvv.isEmpty else {
            return
        }
        
        // Simulate payment processing
        isProcessing = true
        
        // Fake processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            bookingComplete = true
            
            // In a real app, you would update Firestore here
            // to mark these dates as booked
        }
    }
    
    private func generateBookingReference() -> String {
        let letters = "ABCDEFGHJKLMNPQRSTUVWXYZ"
        let numbers = "123456789"
        
        var reference = ""
        for _ in 0..<3 {
            reference.append(letters.randomElement()!)
        }
        reference.append("-")
        for _ in 0..<4 {
            reference.append(numbers.randomElement()!)
        }
        
        return reference
    }
}

// Update the CarDetailView preview to include our new payment functionality
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
        isOwner: false // Set to false to see the booking button
    )
}
