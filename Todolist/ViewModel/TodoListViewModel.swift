//
//  TodoListViewModel.swift
//  Todolist
//
//  Created by Augustin Desaintfucien on 12/12/2023.
//

import Foundation
import FirebaseFirestore
import SwiftUI

class TodolistViewModel: ObservableObject {
    @Published var itemList: [String: ItemData] = [:]
    @Published var userInput: String = ""
    @Published var prioritySelected: Priority = .minor
    let db = Firestore.firestore()
    @ObservedObject var authViewModel: AuthViewModel


    init(authViewModel: AuthViewModel) {
        itemList = [:]
        self.authViewModel = authViewModel
        fetchDataFromFirestore()
    }

    func fetchDataFromFirestore() {

        db.collection("users").document(authViewModel.currentUser?.uid ?? "").collection("todolist")
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching documents: \(error!)")
                    return
                }

                var updatedItemList: [String: ItemData] = [:]

                for document in snapshot.documents {
                    if let data = document.data() as? [String: String] {
                           let documentID = document.documentID
                        
                        let itemData = ItemData(task: data["task"] ?? "" as String, priority: (data["priority"] ?? "") as String)

                           updatedItemList.merge([documentID: itemData]) { _, new in new }
                       }
                }

                print("Current data: \(updatedItemList)")

                self.itemList = updatedItemList
            }
    }
    
    func addValueToFirestore(uid: String) {
        if(userInput.count > 0){
            let currentDate = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = dateFormatter.string(from: currentDate)
                
            db.collection("users").document(authViewModel.currentUser?.uid ?? "").collection("todolist").document(dateString)
                .setData(["task": userInput, "priority": prioritySelected.rawValue]) { error in
                    if let error = error {
                        print("Error adding document: \(error)")
                    } else {
                        print("Document added successfully!")
                        self.userInput = ""
                    }
                }
        }
        
    }
    
    func deleteItemFromFirestore(key: String, uid: String) {
        db.collection("users").document(authViewModel.currentUser?.uid ?? "").collection("todolist").document(key)
            .delete { error in
                if let error = error {
                    print("Error removing document: \(error)")
                } else {
                    print("Document successfully removed!")
                }
            }
    }
}
