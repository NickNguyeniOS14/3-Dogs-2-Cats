import Foundation

struct Animal: Codable, Equatable, Comparable {
    static func < (lhs: Animal, rhs: Animal) -> Bool {
        lhs.id < rhs.id
    }

    static func == (lhs: Animal, rhs: Animal) -> Bool {
        lhs.id == rhs.id
    }

    let id: Int
    let src: AnimalURL
    let photographer_url: String
}

struct AnimalURL: Codable {
    let portrait: String
}


struct JSONPayload: Codable {
    let page: Int
    let photos: [Animal]
}
