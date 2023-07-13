//
//  FirebaseService.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/12/23.
//

import SwiftUI
import FirebaseAuth

@MainActor
class FirebaseService: ObservableObject {
    
    enum FirebaseError: Error {
        
        case generic(Error)
        case notFound
        case emailAlreadyInUse
        
    }
    
    @Published private(set) var user: FirebaseAuth.User?
    @Published private(set) var currentAccessToken: String?
    
    init() {
        
        self.user = Auth.auth().currentUser
        
        // TODO: - MOVE THIS INTO AUTH SERVICE INSTEAD
        
        if let _ = self.user {
            Task {
                try await getAccessTokenForCurrentUser()
            }
        }
        
    }
    
    func signup(email: String,
                password: String) async throws {
        
        do {
            
            let result = try await Auth.auth().createUser(
                withEmail: email,
                password: password
            )
            
            self.user = result.user
            
            try await getAccessTokenForCurrentUser()
            
        }
        catch(let error) {
            
            if let code = AuthErrorCode.Code(rawValue: error._code) {
                
                switch code {
                case .emailAlreadyInUse: throw FirebaseError.emailAlreadyInUse
                default: throw FirebaseError.generic(error)
                }
                
            }
            
            throw FirebaseError.generic(error)
            
        }
        
    }
    
    func login(email: String,
               password: String) async throws {
        
        do {
            
            let result = try await Auth.auth().signIn(
                withEmail: email,
                password: password
            )
            
            self.user = result.user
            
            try await getAccessTokenForCurrentUser()
            
        }
        catch(let error) {
            throw FirebaseError.generic(error)
        }
        
    }
    
    func login(token: String,
               nonce: String) async throws {
        
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: token,
            rawNonce: nonce
        )
        
        do {
            
            let result = try await Auth.auth().signIn(with: credential)
            self.user = result.user
            
            try await getAccessTokenForCurrentUser()
            
        }
        catch(let error) {
            throw FirebaseError.generic(error)
        }
        
    }
    
    func getAccessTokenForCurrentUser() async throws {
        
        guard let user else { throw FirebaseError.notFound }
        
        do {
            
            let result = try await user.getIDTokenResult()
            self.currentAccessToken = result.token
            
        }
        catch(let error) {
            throw FirebaseError.generic(error)
        }
        
    }
    
    func resetPassword(email: String) async throws {
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        }
        catch(let error) {
            throw FirebaseError.generic(error)
        }
        
    }
    
    func updateEmail(newEmail: String) async throws {
        
        guard let user else { throw FirebaseError.notFound }
        
        do {
            try await user.updateEmail(to: newEmail)
        }
        catch(let error) {
            throw FirebaseError.generic(error)
        }
        
    }
    
    func logout() throws {

        do {
            
            try Auth.auth().signOut()
            
            self.user = nil
            self.currentAccessToken = nil
            
        }
        catch(let error) {
            throw FirebaseError.generic(error)
        }

    }
    
// MARK: - EXAMPLE OF CONVERTING COMPLETION HANDLER INTO ASYNC THROWS METHOD
//    private func testAsync() async throws -> Int {
//        
//        return try await withCheckedThrowingContinuation { continuation in
//            
//            testCompletion { result in
//                
//                switch result {
//                case .success(let successResult):
//                    continuation.resume(returning: successResult)
//                case .failure(let error):
//                    continuation.resume(throwing: error)
//                }
//                
//            }
//            
//        }
//        
//    }
//    
//    private func testCompletion(completion: (Result<Int, Error>) -> Void) {
//        completion(.success(1))
//    }
    
}
