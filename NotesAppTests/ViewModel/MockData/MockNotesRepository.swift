import Foundation
@testable import NotesApp

class MockNotesRepository: NotesRepositoryProtocol {
    var stubbedNotes: [Note] = [
        Note(id: UUID(), title: "Apple", content: "Fruit", createdAt: .now),
        Note(id: UUID(), title: "Banana", content: "Yellow", createdAt: .now),
    ]
    
    var shouldFail = false
    var createNoteCalled = false
    var searchCallCount = 0
    
    func fetchNotes() async throws -> [Note] {
        if shouldFail {
            throw NSError(domain: "Test", code: 1)
        }
        return stubbedNotes
    }
    
    func createNote(title: String, content: String) async throws {
        createNoteCalled = true
        if shouldFail {
            throw NSError(domain: "Test", code: 1)
        }
    }
    
    func updateNote(_ note: Note) async throws -> Note {
        if shouldFail {
            throw NSError(domain: "Test", code: 1)
        }
        return note
    }
    
    func deleteNote(_ note: Note) async throws {
        if shouldFail {
            throw NSError(domain: "Test", code: 1)
        }
    }
    
    func searchNotes(query: String) async throws -> [Note] {
        searchCallCount += 1
        return stubbedNotes.filter { $0.title.contains(query) }
    }
}
