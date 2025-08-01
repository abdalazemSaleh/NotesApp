import CoreData

@objc(NoteEntity)
public class NoteEntity: NSManagedObject {}

extension NoteEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteEntity> {
        return NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var content: String
    @NSManaged public var createdAt: Date
}

extension NoteEntity {
    func toDomain() -> Note {
        return Note(
            id: id,
            title: title,
            content: content,
            createdAt: createdAt
        )
    }
    
    func update(with note: Note) {
        title = note.title
        content = note.content
    }
    
    static func create(from note: Note, in context: NSManagedObjectContext) -> NoteEntity {
        let entity = NoteEntity(context: context)
        entity.id = note.id
        entity.title = note.title
        entity.content = note.content
        entity.createdAt = note.createdAt
        return entity
    }
}
