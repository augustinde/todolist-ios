//
//  ContentView.swift
//  Todolist
//
//  Created by Augustin Desaintfucien on 12/12/2023.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth


class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isSignUp = false

    init() {
        observeAuthState()
    }
    
    func wantSignUp(){
        isSignUp.toggle()
    }

    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            guard error == nil else {
                print("Authentication failed: \(error!.localizedDescription)")
                return
            }
            self?.isAuthenticated = true
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func signUp(email: String, password: String){
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard let user = authResult?.user, error == nil else {
                print("ok")
                return
            }
        }
            
    }
    
    func observeAuthState() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isAuthenticated = user != nil
            self?.currentUser = user
        }
    }
}

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
        if(userInput.count > 1){
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

struct ItemData {
    var task: String
    var priority: String
}

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var isSignUpPresented: Bool = false

    var body: some View {
            NavigationView {
                if authViewModel.isAuthenticated {
                    TodolistScreen(authViewModel: authViewModel)
                        .navigationBarItems(trailing: Button("Sign Out") {
                            authViewModel.signOut()
                        })
                } else {
                    if(authViewModel.isSignUp){
                        SignUpScreen(authViewModel: authViewModel)
                    }else{
                        SignInScreen(authViewModel: authViewModel)
                    }
                }
            }
        }
}

struct SignUpScreen: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Sign Up") {
                authViewModel.signUp(email: email, password: password)
            }
            .padding()
            
            Button("Sign In"){
                authViewModel.wantSignUp()
            }
        }
        .padding()
        .navigationTitle("Sign Up")

    }
}

struct SignInScreen: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $password)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Sign In") {
                authViewModel.signIn(email: email, password: password)
            }
            .padding()
            
            Button("SignUp"){
                authViewModel.wantSignUp()
            }
            
            //NavigationLink("Create Account", destination: CreateAccountScreen())
              //  .padding()
        }
        .padding()
        .navigationTitle("Sign In")
    }
}


enum Priority: String, CaseIterable{
    case major = "MAJOR"
    case minor = "MINOR"
}

struct TodolistScreen: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var viewModel: TodolistViewModel
    @FocusState private var isTextFieldFocused: Bool

    init(authViewModel: AuthViewModel) {
        self._authViewModel = StateObject(wrappedValue: authViewModel)
        self._viewModel = StateObject(wrappedValue: TodolistViewModel(authViewModel: authViewModel))
    }
    
    var body: some View {
        VStack {
            Text("Todolist")
            
            HStack{
                Text("Task: ")
                TextField("Enter task",
                  text: $viewModel.userInput)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle()
                    ).onSubmit {
                        viewModel.addValueToFirestore(uid: authViewModel.currentUser?.uid ?? "")
                        isTextFieldFocused = true
                        print(authViewModel.currentUser?.uid as Any)
                    }
                    .focused($isTextFieldFocused)
            }
            
            HStack{
                Text("Priority: ")
                Picker("Priority", selection: $viewModel.prioritySelected) {
                    ForEach(Priority.allCases, id: \.self) { priority in
                        Text(priority.rawValue).tag(priority)
                    }
                }
            }
            
            Button("Add task"){
                viewModel.addValueToFirestore(uid: authViewModel.currentUser?.uid ?? "")
                isTextFieldFocused = true
            }
            .buttonStyle(.bordered)
            .tint(.pink)

            Spacer(minLength: 10)
            ScrollView{
                VStack{
                    ForEach(viewModel.itemList.sorted(by: { $0.key < $1.key }), id: \.key) { key, itemData in
                        HStack {
                            Text(itemData.task)
                                .padding()
                                .frame(width: UIScreen.main.bounds.width * 0.6, alignment: .leading)
                            if(itemData.priority == Priority.major.rawValue){
                                Text(itemData.priority)
                                    .padding(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.red, lineWidth: 2)
                                    )
                                    .frame(width: UIScreen.main.bounds.width * 0.2, alignment: .leading)
                            }else{
                                Text(itemData.priority)
                                    .padding(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.orange, lineWidth: 2)
                                    )
                                    .frame(width: UIScreen.main.bounds.width * 0.2, alignment: .leading)
                            }
                            
                            Button("Delete") {
                                viewModel.deleteItemFromFirestore(key: key, uid: authViewModel.currentUser?.uid ?? "")
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


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
