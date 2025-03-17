import SwiftUI


struct ContentView: View {
    @State private var searchText = ""
    @Binding var showSignInView: Bool

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                bottomNavigationBar
            }
            .searchable(text: $searchText)
            .navigationTitle("DriveShare")
        }
    }
    private var bottomNavigationBar: some View {
        HStack {
            settingsLink
            Spacer()
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
}

#Preview {
    ContentView(showSignInView: .constant(false))
}
