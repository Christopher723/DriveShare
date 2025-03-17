import SwiftUI


struct ContentView: View {
    @StateObject var firestoreManager = FirestoreManager()
    @State private var searchText = ""
    @Binding var showSignInView: Bool
    let gridItems = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
//        Text("DriveShare").font(.largeTitle).bold().padding(.bottom,-10).padding(.top,10)
        NavigationStack {
            VStack {
                ScrollView{
                    LazyVGrid(columns: gridItems, spacing: 20) {
                        ForEach(firestoreManager.Cars) { Car in
                            VStack(alignment: .leading) {
                                Text(Car.CarModel).font(.headline)
                                Text("\(Car.Pricing)")
                            }
                        }
                    }.onAppear {
                        firestoreManager.fetchData()
                    }
                    
                }
                Spacer()
                bottomNavigationBar
            }
            
        }
        .navigationTitle("DriveShare")
        .searchable(text: $searchText)
        
    }
    private var bottomNavigationBar: some View {
        HStack(spacing: 100){
            settingsLink
            carUpload
            }
    }

    private var settingsLink: some View {
        NavigationLink {
            SettingsView(showSignInView: $showSignInView)
        } label: {
            Image(systemName: "gear")
                .font(.title.weight(.semibold))
                .padding()
                .clipShape(Circle())
                .shadow(radius: 4, x: 0, y: 4)
                .padding(15)
        }
    }
    private var carUpload: some View {
        NavigationLink {
            AddCarView()
        } label: {
            Image(systemName: "car.fill")
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
