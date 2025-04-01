//
//  SettingsView.swift
//  StickerShop
//
//  Created by Christopher Woods on 12/2/24.
//

import SwiftUI
import FirebaseFirestore

@MainActor
final class SettingsViewModel: ObservableObject {
    func logout() throws{
        try AuthenticationManager.shared.signOut()
    }
}
struct Booking: Identifiable, Codable {
    @DocumentID var id: String?
    var carId: String
    var carModel: String
    var ownerId: String
    var renterId: String
    var startDate: Date
    var endDate: Date
    var totalPrice: Double
    var status: BookingStatus
    var timestamp: Date
    var isUserOwner: Bool
    
    enum BookingStatus: String, Codable {
        case pending
        case confirmed
        case completed
        case cancelled
    }
    
    var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}
struct SettingsView: View {
    @Binding var showSignInView: Bool
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var firestoreManager: FirestoreManager
    
    var body: some View {
        VStack {
            List {
                Section {
                    NavigationLink(destination: RentalHistoryView().environmentObject(firestoreManager)) {
                        HStack {
                            Image(systemName: "car.fill")
                                .foregroundColor(.blue)
                            Text("Rental History")
                        }
                    }
                } header: {
                    Text("Account")
                }
                
                Section {
                    Button("Log Out") {
                        Task {
                            do {
                                try viewModel.logout()
                                showSignInView = true
                            } catch {
                                print(error)
                            }
                        }
                    }
                    .foregroundColor(.red)
                } header: {
                    Text("Authentication")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct RentalHistoryView: View {
    @EnvironmentObject var firestoreManager: FirestoreManager
    @State private var rentalHistory: [Booking] = []
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .padding()
            } else if rentalHistory.isEmpty {
                VStack {
                    Image(systemName: "car")
                        .font(.system(size: 50))
                        .padding()
                    Text("No rental history found")
                        .font(.headline)
                    Text("Your past and upcoming rentals will appear here")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
            } else {
                List {
                    ForEach(rentalHistory) { booking in
                        RentalHistoryRow(booking: booking)
                    }
                }
            }
        }
        .navigationTitle("Rental History")
        .onAppear {
            loadRentalHistory()
        }
    }
    
    private func loadRentalHistory() {
        guard let userId = try? AuthenticationManager.shared.getAuthUser().email else {
            isLoading = false
            return
        }
        
        firestoreManager.getUserRentalHistory(userId: userId) { bookings in
            self.rentalHistory = bookings
            self.isLoading = false
        }
    }
}

struct RentalHistoryRow: View {
    let booking: Booking
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(booking.carModel ?? "Unknown Car")
                .font(.headline)
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                Text("\(formatDate(booking.startDate)) - \(formatDate(booking.endDate))")
                    .font(.subheadline)
            }
            
            HStack {
                Image(systemName: "dollarsign.circle")
                    .foregroundColor(.green)
                Text("$\(booking.totalPrice, specifier: "%.2f")")
                    .font(.subheadline)
            }
            
            HStack {
                Image(systemName: "person")
                    .foregroundColor(.gray)
                Text(booking.isUserOwner ? "You rented out" : "You rented")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            StatusBadge(status: booking.status.rawValue)
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct StatusBadge: View {
    let status: String
    
    var body: some View {
        Text(status)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
    
    var statusColor: Color {
        switch status.lowercased() {
        case "confirmed":
            return .green
        case "pending":
            return .orange
        case "cancelled":
            return .red
        case "completed":
            return .blue
        default:
            return .gray
        }
    }
}

#Preview {
    NavigationView {
        SettingsView(showSignInView: .constant(false))
            .environmentObject(FirestoreManager())
    }
}
