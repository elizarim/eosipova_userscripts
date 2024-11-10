import Fluent
import Vapor

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.grouped(User.authenticator()).post("signin", use: signIn(request:))
        routes.post("signup", use: signUp)
    }

    @Sendable
    func signIn(request: Request) async throws -> SignIn.ResponseDTO {
        let user = try request.auth.require(User.self)
        let token = try user.generateToken()
        try await token.save(on: request.db)
        return SignIn.ResponseDTO(token: token.value)
    }

    @Sendable
    func signUp(request: Request) async throws -> SignUp.ResponseDTO {
        try SignUp.RequestDTO.validate(content: request)
        let dto = try request.content.decode(SignUp.RequestDTO.self)
        guard dto.password == dto.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        let existingUser = try await User
            .query(on: request.db)
            .filter(\.$name == dto.name)
            .first()
        if existingUser != nil {
            throw Abort(.conflict, reason: "Username is already taken")
        }
        let user = try User(name: dto.name, passwordHash: Bcrypt.hash(dto.password))
        try await user.save(on: request.db)
        return try SignUp.ResponseDTO(
            user: UserDTO(id: user.requireID(), name: user.name)
        )
    }
}

extension AuthController {
    enum SignUp {
        struct RequestDTO: Content, Validatable {
            var name: String
            var password: String
            var confirmPassword: String

            static func validations(_ validations: inout Validations) {
                validations.add("name", as: String.self, is: !.empty)
                validations.add("password", as: String.self, is: .count(8...))
            }
        }

        struct ResponseDTO: Content {
            var user: UserDTO
        }
    }

    enum SignIn {
        struct ResponseDTO: Content {
            var token: String
        }
    }
}
