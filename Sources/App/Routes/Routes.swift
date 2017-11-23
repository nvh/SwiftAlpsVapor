import Vapor

extension Droplet {
    func setupRoutes() throws {
        get("ping") { req in
            var json = JSON()
            try json.set("ping", "pong")
            return json
        }

        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }


        get("/api/v1/notes", ":id") { req in
            guard let noteId = req.parameters["id"]?.int else {
                throw Abort.badRequest
            }
            guard let note = try Note.find(noteId) else {
                throw Abort.notFound
            }
            return try note.makeJSON()
        }

        post("/api/v1/notes") { req in

            let note = try req.note()
            try note.save()
            return try note.makeJSON()
        }
        
        try resource("posts", PostController.self)
    }
}
