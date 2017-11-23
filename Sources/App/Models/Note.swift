//
//  Note.swift
//  NotesPackageDescription
//
//  Created by Niels van Hoorn on 23/11/2017.
//

import Vapor
import FluentProvider
import HTTP

final class Note: Model {
    var title: String
    var contents: String
    var id: String
    let storage = Storage()

    struct Keys {
        static let id = "id"
        static let contents = "contents"
        static let title = "title"

    }

    init(row: Row) throws {
        title = try row.get("title")
        contents = try row.get("contents")
        id = try row.get("id")
    }

    init(id: String, title: String, contents: String) {
        self.id = id
        self.title = title
        self.contents = contents
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("title", title)
        try row.set("contents", contents)
        try row.set("id", id)
        return row
    }
}

extension Note: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
//            builder.string(Note.Keys.id)
            builder.string(Note.Keys.contents)
            builder.string(Note.Keys.title)
        }
    }

    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}


extension Request {
    /// Create a post from the JSON body
    /// return BadRequest error if invalid
    /// or no JSON
    func note() throws -> Note {
        guard let json = json else { throw Abort.badRequest }
        return try Note(json: json)
    }
}

extension Note: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            id: try json.get(Note.Keys.id),
            title: try json.get(Note.Keys.title),
            contents: try json.get(Note.Keys.contents)
        )
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Note.Keys.id, id)
        try json.set(Note.Keys.contents, contents)
        try json.set(Note.Keys.title, title)
        return json
    }
}
