//
//  ToDoFormView.swift
//  MyToDos
//
//  Created by Stewart Lynch on 2021-04-07.
//

import SwiftUI

struct ToDoFormView: View {
    @EnvironmentObject var dataStore: DataStore
    @ObservedObject var formVM: ToDoFormViewModel
    enum Field {
        case todo
    }
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField:Field?
    var body: some View {
        NavigationView {
                VStack(alignment: .leading) {
                    TextField("ToDo", text: $formVM.name)
                        .focused($focusedField, equals: .todo)
                    Toggle("Completed", isOn: $formVM.completed)
                    Spacer()
                }
            .padding()
            .task {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    focusedField = .todo
                }
                
            }
            .navigationTitle("ToDo")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: cancelButton, trailing: updateSaveButton)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button {
                            focusedField = nil
                        } label: {
                            Image(systemName: "keyboard.chevron.compact.down")
                        }
                    }
                    
                }
            }
        }
    }
}

extension ToDoFormView {
    func updateToDo() {
        let toDo = ToDo(id: formVM.id!, name: formVM.name, completed: formVM.completed)
        Task {
            dataStore.updateToDo(toDo)
        }
        dismiss()
    }
    
    func addToDo() {
        let toDo = ToDo(name: formVM.name)
        Task {
            dataStore.addToDo(toDo)
        }
        dismiss()
    }
    
    var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
    }
    
    var updateSaveButton: some View {
        Button( formVM.updating ? "Update" : "Save",
                action: formVM.updating ? updateToDo : addToDo)
            .disabled(formVM.isDisabled)
    }
}

struct ToDoFormView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoFormView(formVM: ToDoFormViewModel())
            .environmentObject(DataStore())
    }
}
