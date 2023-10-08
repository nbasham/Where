import SwiftUI

struct ContentView: View {
    @State private var locationManager = LocationManager()

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(locationManager.location.debugDescription)
            Button("Update") {
            }
        }

        .padding()
        .onAppear {
            locationManager.startTimer()
        }
        .onDisappear {
            locationManager.stopTimer()
        }
    }
}

#Preview {
    ContentView()
}
