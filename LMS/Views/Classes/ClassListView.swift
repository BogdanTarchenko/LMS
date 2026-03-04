import SwiftUI

struct ClassListView: View {
    @State private var viewModel: ClassListViewModel
    @State private var showCreateSheet = false
    @State private var showJoinSheet = false
    @State private var showActionSheet = false

    init(apiService: APIServiceProtocol = APIService()) {
        _viewModel = State(initialValue: ClassListViewModel(apiService: apiService))
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.classes.isEmpty {
                ProgressView()
            } else if viewModel.classes.isEmpty {
                EmptyStateView(
                    icon: "book.closed",
                    title: "Нет классов",
                    description: "Создайте класс или присоединитесь по коду"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.classes) { classroom in
                            NavigationLink(value: classroom) {
                                ClassCardView(classroom: classroom)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .refreshable {
                    await viewModel.loadClasses()
                }
            }
        }
        .navigationTitle("Мои классы")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showActionSheet = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityIdentifier("add_class_button")
            }
        }
        .confirmationDialog("Добавить класс", isPresented: $showActionSheet) {
            Button("Создать класс") {
                showCreateSheet = true
            }
            Button("Присоединиться по коду") {
                showJoinSheet = true
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateClassSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showJoinSheet) {
            JoinClassSheet(viewModel: viewModel)
        }
        .alert("Ошибка", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            if let msg = viewModel.errorMessage {
                Text(msg)
            }
        }
        .task {
            await viewModel.loadClasses()
        }
        .accessibilityIdentifier("class_list")
    }
}

#Preview {
    NavigationStack {
        ClassListView(apiService: {
            let mock = MockAPIService()
            mock.stubbedClasses = MockData.sampleClasses
            return mock
        }())
    }
}
