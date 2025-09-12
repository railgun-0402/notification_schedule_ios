import SwiftUI

struct EventDetailView: View {
    @StateObject private var viewModel: EventDetailViewModel

    init(event: AppEvent) {
        _viewModel = StateObject(wrappedValue: EventDetailViewModel(event: event))
    }

    var body: some View {
        Form {
            Section("タイトル") {
                TextField("タイトル", text: $viewModel.title)
            }
            Section("開始日時") {
                DatePicker(
                    "",
                    selection: $viewModel.date,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .labelsHidden()
            }
            Section("メモ") {
                TextEditor(text: $viewModel.notes)
                    .frame(minHeight: 80)
            }
            Section("アラーム分前") {
                Stepper("\(viewModel.minutesBefore)分前", value: $viewModel.minutesBefore, in: 0...1440)
            }
        }
        .navigationTitle("予定詳細")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("編集") {
                    Task { await viewModel.update() }
                }
                .disabled(!viewModel.canSave)
            }
        }
        .alert(viewModel.alertMessage, isPresented: $viewModel.showAlert) {
            Button("OK") {}
        }
    }
}
