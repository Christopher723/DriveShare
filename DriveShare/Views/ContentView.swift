import SwiftUI


struct ContentView: View {
    @StateObject var firestoreManager = FirestoreManager()
    @EnvironmentObject private var viewModel: SignInEmaiLViewModel
    @State private var searchText = ""
    @Binding var showSignInView: Bool
    let currentUser = try? AuthenticationManager.shared.getAuthUser().email ?? "No User"
    let gridItems = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
//        Text("DriveShare").font(.largeTitle).bold().padding(.bottom,-10).padding(.top,10)
        NavigationStack {
            VStack {
                ScrollView{
                    LazyVGrid(columns: gridItems, spacing: 20) {
                        ForEach(firestoreManager.Cars, id: \.id) { Car in
                            NavigationLink {
                                CarDetailView(car: Car, isOwner: Car.userId == currentUser)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(Car.CarModel).font(.headline)
                                    Text("$\(Car.Pricing)/day")
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                    }.onAppear {
                        if let currentUser{
                            firestoreManager.fetchData(email: currentUser)
                        }
                    }
                    
                }
                Spacer()
                HStack(spacing: 30){
                    settingsLink
                    carUpload
                    carList
                    }
            }
            
        }
        .navigationTitle("DriveShare")
        .searchable(text: $searchText)
        
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
    private var carList: some View{
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
                //.environmentObject(viewModel) doesnt need to be based down the view chain
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
