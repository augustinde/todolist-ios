//
//  TodoListScreen.swift
//  Todolist
//
//  Created by Augustin Desaintfucien on 12/12/2023.
//

import Foundation
import SwiftUI

struct TodolistScreen: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var todolistViewModel: TodolistViewModel
    @FocusState private var isTextFieldFocused: Bool

    init(authViewModel: AuthViewModel) {
        self._authViewModel = StateObject(wrappedValue: authViewModel)
        self._todolistViewModel = StateObject(wrappedValue: TodolistViewModel(authViewModel: authViewModel))
    }
    
    var body: some View {
        VStack {
            Text("Todolist")
            
            HStack{
                Text("Task: ")
                TextField("Enter task",
                  text: $todolistViewModel.userInput)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle()
                    ).onSubmit {
                        todolistViewModel.addValueToFirestore(uid: authViewModel.currentUser?.uid ?? "")
                        isTextFieldFocused = true
                        print(authViewModel.currentUser?.uid as Any)
                    }
                    .focused($isTextFieldFocused)
            }
            
            HStack{
                Text("Priority: ")
                Picker("Priority", selection: $todolistViewModel.prioritySelected) {
                    ForEach(Priority.allCases, id: \.self) { priority in
                        Text(priority.rawValue).tag(priority)
                    }
                }
            }
            
            Button("Add task"){
                todolistViewModel.addValueToFirestore(uid: authViewModel.currentUser?.uid ?? "")
                isTextFieldFocused = true
            }
            .buttonStyle(.bordered)
            .tint(.green)

            Spacer(minLength: 20)
            Text("Tasks")
                .fontWeight(Font.Weight.bold)
                .frame(alignment: .leading)
            Spacer(minLength: 20)

            ScrollView{
                VStack{
                    ForEach(todolistViewModel.itemList.sorted(by: { $0.value.priority < $1.value.priority }), id: \.key) { key, itemData in
                        HStack {
                            Text(itemData.task)
                                .padding()
                                .frame(width: UIScreen.main.bounds.width * 0.6, alignment: .leading)
                            if(itemData.priority == Priority.major.rawValue){
                                Text(itemData.priority)
                                    .foregroundColor(.red)
                                    .padding(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(.red, lineWidth: 2)
                                    )
                                    .frame(width: UIScreen.main.bounds.width * 0.2, alignment: .leading)
                            }else{
                                Text(itemData.priority)
                                    .foregroundColor(.yellow)
                                    .padding(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(.yellow, lineWidth: 2)
                                    )
                                    .frame(width: UIScreen.main.bounds.width * 0.2, alignment: .leading)
                            }
                            Button {
                                todolistViewModel.deleteItemFromFirestore(key: key, uid: authViewModel.currentUser?.uid ?? "")
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(.red)
                            }
                            .frame(width: UIScreen.main.bounds.width * 0.2)
                        }
                    }
                }
            }
        }
        .padding()
    }
}
