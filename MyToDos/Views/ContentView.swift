//
//  ContentView.swift
//  MyToDos
//
//  Created by Stewart Lynch on 2021-04-07.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataStore: DataStore
    @FocusState private var focusedField: Bool?
    var body: some View {
        NavigationView {
            List() {
                ToDoRow(focusedField: $focusedField)
            }
            .listStyle(.insetGrouped)
            .navigationBarTitle("My ToDos")
            .navigationBarItems(
                trailing:
                    Button {
                        dataStore.newToDo()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
            )
        }.task {
            if FileManager().docExist(named: fileName){
                await dataStore.loadToDosAsync()
            }
        }
        .alert("File Error",
               isPresented: $dataStore.showErrorAlert,
               presenting: dataStore.appError) { appError in
            appError.button
        } message: { appError in
            Text(appError.message)
        }
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
        .searchable(text: $dataStore.filterText, prompt: Text("Filter ToDos"))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DataStore())
    }
}
