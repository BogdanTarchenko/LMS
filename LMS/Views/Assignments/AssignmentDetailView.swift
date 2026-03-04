import SwiftUI

struct AssignmentDetailView: View {
    let assignment: Assignment
    let role: Role

    var body: some View {
        Group {
            switch role {
            case .student:
                AssignmentStudentView(assignment: assignment)
            case .teacher, .owner:
                AssignmentTeacherView(assignment: assignment)
            }
        }
        .navigationTitle(assignment.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
