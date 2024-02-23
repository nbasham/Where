import SwiftUI

struct ContentView: View {
    @State private var locationManager = LocationManager()
    @State var count = 0

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Make sure to turn on Location in Settings->Where")
            Text("\(locationManager.locationCount) of \(locationManager.taskCount)")
            Button("Update") {
                count = locationManager.locationList.locations.count
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
