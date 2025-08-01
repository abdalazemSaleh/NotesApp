import Combine
import Foundation

@MainActor
protocol NotesViewModelProtocol {
    func loadNotes() async
    func createNote(title: String, content: String) async
    func updateNote(_ note: Note) async
    func deleteNote(_ note: Note) async
    func searchNotes(query: String) async
}

class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var filteredNotes: [Note] = []
    @Published var searchQuery: String = ""
    @Published var error: Error?
    @Published var isLoading = false
    
    private let repository: NotesRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: NotesRepositoryProtocol = CoreDataNotesRepository()) {
        self.repository = repository
        setupBindings()
        Task {
            await loadNotes()
        }
    }
    
    private func setupBindings() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] query in
                Task {
                    await self?.searchNotes(query: query)
                }
            }
            .store(in: &cancellables)
    }
}

extension NotesViewModel: NotesViewModelProtocol {
    func loadNotes() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let notes = try await repository.fetchNotes()
            self.notes = notes
            self.filteredNotes = notes
        } catch {
            self.error = error
        }
    }
    
    func createNote(title: String, content: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let _ = try await repository.createNote(title: title, content: content)
            await loadNotes()
        } catch {
            self.error = error
        }
    }
    
    func updateNote(_ note: Note) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let _ = try await repository.updateNote(note)
            await loadNotes()
        } catch {
            self.error = error
        }
    }
    
    func deleteNote(_ note: Note) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let _ = try await repository.deleteNote(note)
            await loadNotes()
        } catch {
            self.error = error
        }
    }
    
    func searchNotes(query: String) async {
        if query.isEmpty {
            filteredNotes = notes
        } else {
            isLoading = true
            defer { isLoading = false }
            
            do {
                let notes = try await repository.searchNotes(query: query)
                filteredNotes = notes
            } catch {
                self.error = error
            }
        }
    }
}
