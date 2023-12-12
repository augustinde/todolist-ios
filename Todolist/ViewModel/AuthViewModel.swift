//
//  AuthViewModel.swift
//  Todolist
//
//  Created by Augustin Desaintfucien on 12/12/2023.
//

import Foundation
import SwiftUI
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isSignUp = false
    @Published var error = false
    @Published var errorMsg: String = ""

    init() {
        observeAuthState()
    }
    
    func wantSignUp(){
        isSignUp.toggle()
    }

    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            guard error == nil else {
                self?.errorMsg = error!.localizedDescription
                self?.error.toggle()
                return
            }
            self?.isAuthenticated = true
            self?.errorMsg = ""
            self?.error.toggle()
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
                self.errorMsg = error!.localizedDescription
                self.error.toggle()
                return
            }
            self.errorMsg = ""
            self.error.toggle()
        }
            
    }
    
    func observeAuthState() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isAuthenticated = user != nil
            self?.currentUser = user
        }
    }
}
