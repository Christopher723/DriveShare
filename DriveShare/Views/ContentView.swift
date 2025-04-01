import SwiftUI
import CoreLocation
import MapKit

struct ContentView: View {
    @EnvironmentObject var firestoreManager: FirestoreManager
    @EnvironmentObject private var viewModel: SignInEmaiLViewModel
    @Binding var showSignInView: Bool
    let currentUser = try? AuthenticationManager.shared.getAuthUser().email ?? "No User"
    let gridItems = [GridItem(.flexible()), GridItem(.flexible())]
    
    // Search parameters
    @State private var searchText = ""
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    @State private var locationSearch = ""
    @State private var searchLocation: CLLocationCoordinate2D?
    @State private var searchRadius: Double = 50 // Search radius in kilometers
    @State private var showAdvancedSearch = false
    
    var filteredCars: [Car] {
        var filtered = firestoreManager.Cars
        
        // Filter by text (model or price)
        if !searchText.isEmpty {
            filtered = filtered.filter { car in
                car.CarModel.lowercased().contains(searchText.lowercased()) ||
                String(car.Pricing).contains(searchText)
            }
        }
        
        // Filter by date availability
        if showDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: selectedDate)
            
            filtered = filtered.filter { car in
                car.Availability.contains(dateString)
            }
        }
        
        // Filter by location
        if let userLocation = searchLocation {
            filtered = filtered.filter { car in
                let carLocation = CLLocation(latitude: car.PickUpLocation.latitude,
                                           longitude: car.PickUpLocation.longitude)
                let userCLLocation = CLLocation(latitude: userLocation.latitude,
                                              longitude: userLocation.longitude)
                
                // Calculate distance in kilometers
                let distance = carLocation.distance(from: userCLLocation) / 1000
                return distance <= searchRadius
            }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Advanced search panel
                if showAdvancedSearch {
                    VStack(spacing: 10) {
                        // Date picker
                        HStack {
                            Toggle("Filter by date", isOn: $showDatePicker)
                                .font(.subheadline)
                            
                            if showDatePicker {
                                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                    .labelsHidden()
                            }
                        }
                        .padding(.horizontal)
                        
                        // Location search
                        HStack {
                            Image(systemName: "location.circle")
                                .foregroundColor(.gray)
                            
                            TextField("Search by location", text: $locationSearch)
                                .onChange(of: locationSearch) {_, newValue in
                                    // Convert address to coordinates (simplified)
                                    // In a real app, you'd use CLGeocoder or a Maps API
                                    geocodeAddress(newValue)
                                }
                            
                            if !locationSearch.isEmpty {
                                Button(action: {
                                    self.locationSearch = ""
                                    self.searchLocation = nil
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        
                        // Radius slider
                        if searchLocation != nil {
                            HStack {
                                Text("Within: \(Int(searchRadius)) km")
                                    .font(.subheadline)
                                
                                Slider(value: $searchRadius, in: 5...200, step: 5)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6).opacity(0.5))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search cars by model or price", text: $searchText)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            self.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button(action: {
                        withAnimation {
                            showAdvancedSearch.toggle()
                        }
                    }) {
                        Image(systemName: showAdvancedSearch ? "chevron.up" : "chevron.down")
                            .foregroundColor(.gray)
                    }
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Results count
                Text("\(filteredCars.count) cars found")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                ScrollView {
                    LazyVGrid(columns: gridItems, spacing: 20) {
                        ForEach(filteredCars, id: \.id) { Car in
                            NavigationLink {
                                CarDetailView(car: Car, isOwner: Car.userId == currentUser).environmentObject(firestoreManager)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(Car.CarModel).font(.headline)
                                    Text("$\(Car.Pricing)/day")
                                    
                                    if showDatePicker && Car.Availability.contains(dateFormatter.string(from: selectedDate)) {
                                        Text("Available on selected date")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    .onAppear {
                        if let currentUser {
                            firestoreManager.setupRealTimeListener(email: currentUser, isUserCars: false)
                        }
                    }
                    .onDisappear {
                        firestoreManager.removeListener()
                    }
                }
                
                Spacer()
                
                HStack(spacing: 20) {
                    settingsLink
                    carUpload
                    messagingLink
                    carList
                }
            }
        }
        .navigationTitle("DriveShare")
    }
    
    // Date formatter for availability checks
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    // Function to convert address to coordinates
    private func geocodeAddress(_ address: String) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            
            if let location = placemarks?.first?.location?.coordinate {
                self.searchLocation = location
            }
        }
    }
    
    // Your existing view components
    private var settingsLink: some View {
        NavigationLink {
            SettingsView(showSignInView: $showSignInView).environmentObject(firestoreManager)
        } label: {
            Image(systemName: "gear")
                .font(.title.weight(.semibold))
                .padding()
                .clipShape(Circle())
                .shadow(radius: 4, x: 0, y: 4)
                .padding(15)
        }
    }

    private var carList: some View {
        NavigationLink {
            UsersCarListView().environmentObject(firestoreManager)
        } label: {
            Image(systemName: "list.bullet.clipboard.fill")
                .font(.title.weight(.semibold))
                .padding()
                .clipShape(Circle())
                .shadow(radius: 4, x: 0, y: 4)
                .padding(15)
        }
    }
    
    private var carUpload: some View {
        NavigationLink {
            AddCarView().environmentObject(firestoreManager)
        } label: {
            Image(systemName: "car.fill")
                .font(.title.weight(.semibold))
                .padding()
                .clipShape(Circle())
                .shadow(radius: 4, x: 0, y: 4)
                .padding(15)
        }
    }
    private var messagingLink: some View {
        NavigationLink {
            MessagingView().environmentObject(firestoreManager)
        } label: {
            Image(systemName: "message.fill")
                .font(.title.weight(.semibold))
                .padding()
                .clipShape(Circle())
                .shadow(radius: 4, x: 0, y: 4)
                .padding(15)
        }
    }
}


#Preview {
    ContentView(showSignInView: .constant(false))
}
