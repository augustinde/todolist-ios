//
//  ContentView.swift
//  Todolist
//
//  Created by Augustin Desaintfucien on 12/12/2023.
//

import SwiftUI

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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
