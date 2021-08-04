//
//  ToDoRow.swift
//  ToDoRow
//
//  Created by Stewart Lynch on 2021-07-31.
//

import SwiftUI

struct ToDoRow: View {
    @EnvironmentObject var dataStore: DataStore
    var focusedField: FocusState<Bool?>.Binding
    var body: some View {
        ForEach($dataStore.filteredToDos) { $toDo in
            TextField(toDo.name, text: $toDo.name)
                .font(.title3)
                .foregroundColor(toDo.completed ? .green : Color(.label))
                .focused(focusedField, equals: true)
                .overlay(
                    Rectangle()
                        .fill(Color.green)
                        .frame(height: 1)
                        .opacity(toDo.completed ? 1 : 0)
                )
                .onSubmit {
                    dataStore.updateToDo(toDo)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        withAnimation {
                            dataStore.deleteTodo(toDo)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading) {
                    Button {
                        toDo.completed.toggle()
                        dataStore.updateToDo(toDo)
                    } label: {
                        Text(toDo.completed ? "Remove Completion" : "Completed")
                    }.tint(.teal)
                }
        }
    }
}

