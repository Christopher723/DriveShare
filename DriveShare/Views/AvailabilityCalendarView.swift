//
//  AvailabilityCalendarView.swift
//  DriveShare
//
//  Created by Christopher Woods on 3/27/25.
//
import SwiftUI

struct AvailabilityCalendarView: View {
    let unavailableDates: [String] // Renamed to clarify these are unavailable dates
    @State private var selectedDate: Date? = nil
    @State private var currentMonth: Date = Date()
    
    // Convert string dates to Date objects
    private var unavailableDateObjects: [Date] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return unavailableDates.compactMap { formatter.date(from: $0) }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // Month navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(monthYearString(from: currentMonth))
                    .font(.headline)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Weekday headers
            HStack {
                ForEach(getWeekdaySymbols(), id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 8)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(getDaysInMonth(), id: \.self) { date in
                    if let date = date {
                        let isAvailable = isDateAvailable(date)
                        let isSelected = isDateSelected(date)
                        
                        Button(action: {
                            if isAvailable {
                                selectedDate = date
                            }
                        }) {
                            Text(dayString(from: date))
                                .frame(height: 40)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(backgroundForDate(date, isAvailable: isAvailable, isSelected: isSelected))
                                )
                                .foregroundColor(foregroundForDate(date, isAvailable: isAvailable))
                        }
                        .disabled(!isAvailable)
                    } else {
                        // Empty cell for padding
                        Text("")
                            .frame(height: 40)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            
            // Legend
            HStack(spacing: 16) {
                HStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 16, height: 16)
                    Text("Available")
                        .font(.caption)
                }
                
                HStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.red.opacity(0.2))
                        .frame(width: 16, height: 16)
                    Text("Unavailable")
                        .font(.caption)
                }
                
                HStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.blue)
                        .frame(width: 16, height: 16)
                    Text("Selected")
                        .font(.caption)
                }
            }
            .padding(.top, 8)
        }
        .padding()
    }
    
    // Helper functions
    private func previousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newDate
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func dayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private func getWeekdaySymbols() -> [String] {
        return Calendar.current.shortWeekdaySymbols
    }
    
    private func getDaysInMonth() -> [Date?] {
        let calendar = Calendar.current
        
        // Get start of the month
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        guard let startOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: startOfMonth) else {
            return []
        }
        
        // Get weekday of the first day (0 is Sunday, 1 is Monday, etc.)
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        
        // Create array with empty slots for days before the first day of month
        var days = Array(repeating: nil as Date?, count: firstWeekday - 1)
        
        // Add all days of the month
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    // FLIPPED LOGIC: Date is available if it's NOT in the unavailableDates array
    private func isDateAvailable(_ date: Date) -> Bool {
        let calendar = Calendar.current
        // Check if the date is in the past
        if date < Calendar.current.startOfDay(for: Date()) {
            return false
        }
        
        // Check if the date is in the unavailable dates list
        return !unavailableDateObjects.contains { unavailableDate in
            calendar.isDate(unavailableDate, inSameDayAs: date)
        }
    }
    
    private func isDateSelected(_ date: Date) -> Bool {
        guard let selectedDate = selectedDate else { return false }
        return Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
    
    private func backgroundForDate(_ date: Date, isAvailable: Bool, isSelected: Bool) -> Color {
        if isSelected {
            return .blue
        } else if isAvailable {
            return .green.opacity(0.2) // Available dates are green
        } else {
            return .red.opacity(0.2) // Unavailable dates are red
        }
    }
    
    private func foregroundForDate(_ date: Date, isAvailable: Bool) -> Color {
        if isDateSelected(date) {
            return .white
        } else if date < Calendar.current.startOfDay(for: Date()) {
            return .gray // Past dates are gray
        } else if isAvailable {
            return .primary
        } else {
            return .primary
        }
    }
}
