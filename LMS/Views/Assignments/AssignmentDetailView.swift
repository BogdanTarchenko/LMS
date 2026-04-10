import SwiftUI

struct AssignmentDetailView: View {
    let assignment: Assignment
    let role: Role
    let classId: String

    var body: some View {
        Group {
            switch role {
            case .student:
                AssignmentStudentView(assignment: assignment, classId: classId)
            case .teacher, .owner:
                AssignmentTeacherView(assignment: assignment)
            }
        }
        .navigationTitle(assignment.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
