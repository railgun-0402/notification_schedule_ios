import SwiftUI

struct AddEventView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddEventViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section("タイトル") {
                    TextField("タイトル", text: $viewModel.title)
                }
                Section("開始日時") {
                    DatePicker("", selection: $viewModel.date, in: Date()..., displayedComponents: [.date, .hourAndMinute])
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
            .navigationTitle("予定を追加")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Task { await viewModel.save() }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .alert(viewModel.alertMessage, isPresented: $viewModel.showAlert) {
                Button("OK") {
                    if viewModel.isSuccess { dismiss() }
                }
            }
        }
    }
}
