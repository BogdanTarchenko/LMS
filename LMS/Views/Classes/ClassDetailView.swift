import SwiftUI

struct ClassDetailView: View {
    let classroom: ClassRoom

    var body: some View {
        Text("ClassDetailView Placeholder: \(classroom.name)")
            .navigationTitle(classroom.name)
    }
}

#Preview {
    NavigationStack {
        ClassDetailView(classroom: MockData.sampleClasses[0])
    }
}
