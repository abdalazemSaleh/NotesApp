import CoreData
import Combine

class CoreDataNotesRepository: NotesRepositoryProtocol {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.context = context
    }
    
    func fetchNotes() async throws -> [Note] {
        let request = NoteEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let results = try self.context.fetch(request)
            let notes = results.map { $0.toDomain() }
            return notes
        } catch {
            throw error
        }
    }
    
    func createNote(title: String, content: String) async throws {
        let note = Note(title: title, content: content)
        do {
            _ = NoteEntity.create(from: note, in: self.context)
            try self.context.save()
        } catch {
            throw error
        }
    }
    
    func updateNote(_ note: Note) async throws -> Note {
        let request = NoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", note.id as CVarArg)
        
        do {
            if let entity = try self.context.fetch(request).first {
                entity.update(with: note)
                try self.context.save()
                return note
            } else {
                throw CoreDataError.objectNotFound
            }
        } catch {
            throw error
        }
    }
    
    func deleteNote(_ note: Note) async throws {
        let request = NoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", note.id as CVarArg)
        
        do {
            if let entity = try self.context.fetch(request).first {
                self.context.delete(entity)
                try self.context.save()
            } else {
                throw CoreDataError.objectNotFound
            }
        } catch {
            throw error
        }
    }
    
    func searchNotes(query: String) async throws -> [Note] {
        let request = NoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR content CONTAINS[cd] %@", query, query)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let results = try self.context.fetch(request)
            let notes = results.map { $0.toDomain() }
            return notes
        } catch {
            throw error
        }
    }
}

enum CoreDataError: Error {
    case objectNotFound
}
