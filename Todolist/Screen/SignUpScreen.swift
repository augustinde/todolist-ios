//
//  SignUpScreen.swift
//  Todolist
//
//  Created by Augustin Desaintfucien on 12/12/2023.
//

import Foundation
import SwiftUI
import AlertToast

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
            .buttonStyle(.bordered)
            .tint(.pink)
            
            Button("Sign In"){
                authViewModel.wantSignUp()
            }
            
        }
        .padding()
        .navigationTitle("Sign Up")
        .toast(isPresenting: $authViewModel.error){
            AlertToast(type: .regular, title: authViewModel.errorMsg)
        }
    }
}
