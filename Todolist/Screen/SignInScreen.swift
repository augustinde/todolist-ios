//
//  SignInScreen.swift
//  Todolist
//
//  Created by Augustin Desaintfucien on 12/12/2023.
//

import Foundation
import SwiftUI
import AlertToast

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
            .buttonStyle(.bordered)
            .tint(.pink)
            
            Button("SignUp"){
                authViewModel.wantSignUp()
            }
        }
        .padding()
        .navigationTitle("Sign In")
        .toast(isPresenting: $authViewModel.error){
            AlertToast(type: .regular, title: authViewModel.errorMsg)
        }
    }
}
