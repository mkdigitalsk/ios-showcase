enum AuthError: Error, Equatable {
    case invalidCredentials
    case emailTaken
    case sessionExpired
    case offline
    case unavailable
}
