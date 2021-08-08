//
//  DataStore.swift
//  MyToDos
//
//  Created by Stewart Lynch on 2021-04-07.
//

import Foundation

@MainActor
class DataStore: ObservableObject {
    @Published var toDos:[ToDo] = []
    @Published var appError: ErrorType? = nil
    @Published var showErrorAlert = false
    @Published var filterText = "" {
        didSet {
            filterToDos()
        }
    }
    
    @Published var filteredToDos: [ToDo] = []
    init() {
        print(FileManager.docDirURL.path)
    }
    
    private func filterToDos() {
        if !filterText.isEmpty {
            filteredToDos = toDos.filter{$0.name.lowercased().contains(filterText.lowercased())}
        } else {
            filteredToDos = toDos
        }
    }
    

    func newToDo() {
        addToDo(ToDo(name: ""))
    }
    
    func addToDo(_ toDo: ToDo) {
        toDos.append(toDo)
        saveToDosThrows()
        filteredToDos = toDos
    }
    
    func updateToDo(_ toDo: ToDo) {
        guard let index = toDos.firstIndex(where: { $0.id == toDo.id}) else { return }
        toDos[index] = toDo
        saveToDosThrows()
    }
    
    func deleteToDo(at indexSet: IndexSet) {
        toDos.remove(atOffsets: indexSet)
        saveToDosThrows()
    }
    
    func deleteTodo(_ toDo: ToDo) {
        if let toDoToDeleteIndex = toDos.firstIndex(where: {$0.id == toDo.id}) {
            toDos.remove(at: toDoToDeleteIndex)
            saveToDosThrows()
            filterToDos()
        }
    }
    
    func loadToDos() {
        FileManager().readDocument(docName: fileName) { (result) in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    toDos = try decoder.decode([ToDo].self, from: data)
                } catch {
                    //                    print(ToDoError.decodingError.localizedDescription)
                    appError = ErrorType(error: .decodingError)
                    showErrorAlert = true
                }
            case .failure(let error):
                //                print(error.localizedDescription)
                appError = ErrorType(error: error)
                showErrorAlert = true
            }
        }
    }
    
    func loadToDos2() {
        do {
            let data = try FileManager().readDocument(docName: fileName)
            let decoder = JSONDecoder()
            do {
                toDos = try decoder.decode([ToDo].self, from: data)
                filteredToDos = toDos
            } catch {
                appError = ErrorType(error: .decodingError)
                showErrorAlert = true
            }
        } catch {
            appError = ErrorType(error: error as! ToDoError)
            showErrorAlert = true
        }
    }
    
    func saveToDos() {
        print("Saving toDos to file system")
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(toDos)
            let jsonString = String(decoding: data, as: UTF8.self)
            FileManager().saveDocument(contents: jsonString, docName: fileName) { (error) in
                if let error = error {
                    //                    print(error.localizedDescription)
                    appError = ErrorType(error: error)
                    showErrorAlert = true
                }
            }
        } catch {
            //            print(ToDoError.encodingError.localizedDescription)
            appError = ErrorType(error: .encodingError)
            showErrorAlert = true
        }
    }
    
    func saveToDosThrows() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(toDos)
            let jsonString = String(decoding: data, as: UTF8.self)
            do {
            try FileManager().saveDocument(contents: jsonString, docName: fileName)
            } catch {
                appError = ErrorType(error: error as! ToDoError)
                showErrorAlert = true
            }
        } catch {
            appError = ErrorType(error: .encodingError)
            showErrorAlert = true
        }
        
    }
}
