////
////  BookingViewModel.swift
////  DriveShare
////
////  Created by Christopher Woods on 4/1/25.
////
//
//import SwiftUI
//
//class BookingViewModel: ObservableObject {
//    @Published var bookingComplete: Bool = false
//    private var observers: [Observer] = []
//    func addObserver(observer: Observer) {
//        observers.append(observer)
//    }
//    func removeObserver(observer: Observer) {
//        observers.removeAll { $0 === observer }
//    }
//    func notifyObservers() {
//        for observer in observers {
//            observer.update()
//        }
//    }
//    func setBookingComplete(value: Bool) {
//        bookingComplete = value
//        notifyObservers()
//    }
//}
//protocol Observer: AnyObject {
//    func update()
//    struct BookingConfirmationView: View, Observer {
//        @ObservedObject var viewModel: BookingViewModel
//        var body: some View {
//            VStack {
//                if viewModel.bookingComplete {
//                    Image(systemName: "checkmark.circle.fill")
//                        .resizable()
//                        .frame(width: 100, height: 100)
//                        .foregroundColor(.green)
//                    Text("Booking Confirmed!")
//                        .font(.title)
//                        .bold()
//                    Text("Your car is reserved from \(startDate, style: .date) to \(endDate, style: .date)")
//                        .multilineTextAlignment(.center)
//                    Text("Booking Reference: \(generateBookingReference())")
//                        .font(.headline)
//                        .padding()
//                        .background(Color.gray.opacity(0.1))
//                        .cornerRadius(8)
//                    Button("Done") {
//                        dismiss()
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//                }
//            }
//            .onAppear {
//                viewModel.addObserver(observer: self)
//            }
//            .onDisappear {
//                viewModel.removeObserver(observer: self)
//            }
//        }
//        func update() {
//            // This method gets called whenever
//            bookingComplete
//            
//            // Handle UI updates based on the new state here.
//        }
//    }
//    private func processPayment() {
//        // Validate input
//        guard !cardNumber.isEmpty, !cardholderName.isEmpty,
//              !expiryDate.isEmpty, !cvv.isEmpty else {
//            return
//        }
//        // Simulate payment processing
//        isProcessing = true
//        // Fake processing delay
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            isProcessing = false
//            viewModel.setBookingComplete(value: true) // This triggers the Observer to update
//            // Send message to car owner about the booking
//            if let carOwnerId = car.userId {
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateStyle =
//                    .medium
//                let bookingMessage = "I've booked your \(car.CarModel) from
//                \(dateFormatter.string(from: startDate)) to \(dateFormatter.string(from: endDate)). Booking
//                reference: \(generateBookingReference())"
//                firestoreManager.sendMessage(
//                    to: carOwnerId,
//                    content: bookingMessage,
//                    relatedCarId: car.id
//                )
//            }
//        }
//    }
//}
