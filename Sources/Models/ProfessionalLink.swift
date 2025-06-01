import Foundation
import GRDB
import SharingGRDB

@Table
public struct ProfessionalLink: Identifiable, Sendable, Equatable {
    public var id: Int64?
    public var createdAt: Date
    public var title: String
    public var link: String
    public var image: String

    public init(
        id: Int64? = nil,
        createdAt: Date,
        title: String,
        link: String,
        image: String

    ) {
        self.id = id
        self.createdAt = createdAt
        self.title = title
        self.link = link
        self.image = image
    }
}

public extension ProfessionalLink {
    static var github: ProfessionalLink {
        ProfessionalLink(
            createdAt: Date(),
            title: "GitHub",
            link: "https://github.com",
            image: "terminal"
        )
    }
}
