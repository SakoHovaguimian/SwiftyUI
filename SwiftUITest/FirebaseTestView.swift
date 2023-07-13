//
//  FirebaseTestView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/12/23.
//

import SwiftUI
import CryptoKit
import AuthenticationServices

struct FirebaseTestView: View {
    
    @ObservedObject var firebaseService: FirebaseService
    
    @State private var currentNonce: String?
    
    var body: some View {
        
        ZStack {
            
            AppColor
                .eggShell
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                
                Group {
                    
                    Text("Is User Logged in: \(firebaseService.user?.uid ?? "NA")")
                    Text("Current Token: \(firebaseService.currentAccessToken ?? "NA")")
                    
                }
                .foregroundStyle(Color.black)
                
                Button("Sign Up") {
                    signUp()
                }
                
                Button("Login") {
                    login()
                }
                
                Button("Logout") {
                    try! firebaseService.logout()
                }
                
                SignInWithAppleButton { request in
                    
                    let nonce = randomNonceString()
                    currentNonce = nonce
                    request.requestedScopes = [.fullName, .email]
                    request.nonce = sha256(nonce)
                    
                } onCompletion: { result in
                    
                    switch result {
                    case .success(let authorization): handleAppleLogin(authorization: authorization)
                    case .failure(let error): print(error)
                    }
                        
                }
                .frame(
                    maxWidth: 200,
                    maxHeight: 50
                )
                
            }
            
        }
        
    }
    
    private func signUp() {
        
        Task {
            
            do {
                
                try await firebaseService.signup(
                    email: "sako@me.com",
                    password: "123456"
                )
                
            }
            catch(let error) {
                print(error)
            }
            
        }
        
    }
    
    private func login() {
        
        Task {
            
            do {
                
                try await firebaseService.login(
                    email: "sako@me.com",
                    password: "123456"
                )
                
            }
            catch(let error) {
                print(error)
            }
            
        }
        
    }
    
    private func handleAppleLogin(authorization: ASAuthorization) {
        
        switch authorization.credential {
            
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            guard let nonce = self.currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            Task {
                
                try await self.firebaseService
                    .login(
                        token: idTokenString,
                        nonce: nonce
                    )
                
            }

        default: print("Something went wrong")
            
        }
        
    }
    
}
