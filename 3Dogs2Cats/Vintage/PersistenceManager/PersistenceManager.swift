import Foundation
import UIKit

enum PersistenceActionType {
  case add, remove
}

enum PersistenceManager {
  
  static private let defaults = UserDefaults.standard
  
  enum Keys {
    static let favorites = "favorites"
    
  }
  
  static func updateWith(favorite: Data,
                         actionType: PersistenceActionType,
                         completed: @escaping (NetworkError?) -> Void) {
    retrieveFavorites { result in
      switch result {
        case .success(var favorites):
          switch actionType {
            case .add:
              guard !favorites.contains(favorite) else {
                completed(.alreadyInFavorites)
                return
              }
              
              favorites.append(favorite)
              
            case .remove:
              favorites.removeAll()
          }
          
          completed(save(favorites: favorites))
          
        case .failure(let error):
          completed(error)
      }
    }
  }
  
  
  static func retrieveFavorites(completed: @escaping (Result<[Data], NetworkError>) -> Void) {
    
    guard let favoritesData = defaults.object(forKey: Keys.favorites) as? Data else {
      completed(.success([]))
      return
    }
    
    do {
      let decoder = JSONDecoder()
      
      let favorites = try decoder.decode([Data].self, from: favoritesData)
      completed(.success(favorites))
    } catch {
      print(error.localizedDescription)
      completed(.failure(.unableToFavorite))
    }
  }
  
  
  static func save(favorites: [Data]) -> NetworkError? {
    do {
      let encoder = JSONEncoder()
      
      let encodedFavorites = try encoder.encode(favorites)
      defaults.set(encodedFavorites, forKey: Keys.favorites)
      return nil
    } catch {
      return .unableToFavorite
    }
  }
}
