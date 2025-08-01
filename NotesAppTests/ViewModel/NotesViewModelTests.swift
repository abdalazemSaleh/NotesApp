import Testing
@testable import NotesApp

@Suite("Test NotesViewModel")
struct NotesViewModelTests {
    
    let vm: NotesViewModel

    init() {
        let mockRepository = MockNotesRepository()
        vm = NotesViewModel(repository: mockRepository)
    }
        
    @Test
    func testInitialState() async throws {
        #expect(vm.notes.isEmpty)
        #expect(vm.filteredNotes.isEmpty)
        #expect(vm.error == nil)
        await Task.yield()
        #expect(vm.isLoading == false)
    }
    
    @Test func testLoadNotesSuccess() async throws {
        await vm.loadNotes()

        #expect(vm.notes.count == 2)
        #expect(vm.filteredNotes.count == 2)
        #expect(vm.isLoading == false)
    }
    
    @Test func testLoadNotesFailure() async throws {
        let mockRepository = MockNotesRepository()
        mockRepository.shouldFail = true
        let vm = NotesViewModel(repository: mockRepository)
        
        await vm.loadNotes()
        
        #expect(vm.notes.isEmpty)
        #expect(vm.error != nil)
    }
    
    @Test func testCreateNoteSuccess() async throws {
        let mockRepository = MockNotesRepository()
        let vm = NotesViewModel(repository: mockRepository)
        
        await vm.createNote(title: "Test", content: "Content")
        
        #expect(mockRepository.createNoteCalled == true)
        #expect(vm.error == nil)
    }
    
    @Test func testSearchNotes() async throws {
        await vm.loadNotes()
        
        await vm.searchNotes(query: "Apple")
        
        #expect(vm.filteredNotes.count == 1)
        #expect(vm.filteredNotes.first?.title == "Apple")
    }
    
    @Test func testSearchDebouncing() async throws {
        let mockRepository = MockNotesRepository()
        let vm = NotesViewModel(repository: mockRepository)
        
        vm.searchQuery = "A"
        vm.searchQuery = "Ap"
        vm.searchQuery = "App"
        vm.searchQuery = "Appl"
        vm.searchQuery = "Apple"
        
        try await Task.sleep(for: .milliseconds(350))
        
        #expect(mockRepository.searchCallCount == 1)
    }
}

