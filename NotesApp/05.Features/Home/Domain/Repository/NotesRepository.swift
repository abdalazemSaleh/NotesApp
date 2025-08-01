import Combine

protocol NotesRepositoryProtocol {
    func fetchNotes() async throws -> [Note]
    func createNote(title: String, content: String) async throws
    func updateNote(_ note: Note) async throws -> Note
    func deleteNote(_ note: Note) async throws
    func searchNotes(query: String) async throws -> [Note]
}
