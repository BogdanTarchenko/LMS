import SwiftUI

struct GradeView: View {
    let grade: Int

    private var color: Color {
        switch grade {
        case 90...100: .green
        case 70..<90: .blue
        case 50..<70: .orange
        default: .red
        }
    }

    var body: some View {
        Text("\(grade)")
            .font(.subheadline)
            .fontWeight(.bold)
            .monospacedDigit()
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    HStack(spacing: 8) {
        GradeView(grade: 95)
        GradeView(grade: 80)
        GradeView(grade: 65)
        GradeView(grade: 40)
    }
    .padding()
}
