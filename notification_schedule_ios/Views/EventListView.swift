import SwiftUI
import EventKit
import UIKit

struct EventListView: View {
    @StateObject private var viewModel = EventListViewModel()
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("予定一覧")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showAdd = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(
                    isPresented: $showAdd,
                    onDismiss: {
                        Task { await viewModel.loadEvents() }
                    },
                    content: {
                        AddEventView()
                    }
                )
                .alert("エラー", isPresented: $viewModel.showError) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(viewModel.errorMessage)
                }
                .task { await viewModel.onAppear() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.authorizationStatus {
        case .authorized:
            if viewModel.events.isEmpty {
                EmptyStateView()
            } else {
                List {
                    ForEach(viewModel.events) { event in
                        VStack(alignment: .leading) {
                            Text(event.title).font(.headline)
                            Text(event.startDate, style: .date)
                            Text(event.startDate, style: .time)
                        }
                    }
                    .onDelete { indexSet in
                        viewModel.delete(at: indexSet)
                    }
                }
                .listStyle(.plain)
            }
        case .denied, .restricted:
            VStack(spacing: 16) {
                Text("カレンダーのアクセスが許可されていません。設定を開いて許可してください。")
                    .multilineTextAlignment(.center)
                Button("設定を開く") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        default:
            ProgressView()
        }
    }
}
