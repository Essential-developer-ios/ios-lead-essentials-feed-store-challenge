import Foundation
import RealmSwift

final class RealmFeedImage: Object {
	@objc dynamic var id: String = ""
	@objc dynamic var imageDescription: String?
	@objc dynamic var location: String?
	@objc dynamic var url: String = ""

	convenience init(id: String, imageDescription: String?, location: String?, url: String) {
		self.init()
		self.id = id
		self.imageDescription = imageDescription
		self.location = location
		self.url = url
	}
}

final class RealmFeed: Object {
	@objc dynamic var timestamp: Date = .init()
	var realmFeedImages: List<RealmFeedImage> = .init()

	convenience init(timestamp: Date, realmFeedImages: [RealmFeedImage]) {
		self.init()
		self.timestamp = timestamp
		self.realmFeedImages.append(objectsIn: realmFeedImages)
	}
}

public final class RealmFeedStore: FeedStore {
	private let realm: Realm

	public init() throws {
		self.realm = try Realm()
	}

	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		do {
			try realm.write {
				realm.deleteAll()
			}
			completion(nil)
		} catch {
			completion(error)
		}
	}

	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		deleteCachedFeed { [weak self] error in
			guard let self = self else { return completion(error) }

			self.insertTo(feed, timestamp: timestamp, completion: completion)
		}
	}

	public func retrieve(completion: @escaping RetrievalCompletion) {
		if let realmFeed = realm.objects(RealmFeed.self).first, !realmFeed.realmFeedImages.isEmpty {
			completion(
				.found(
					feed: realmFeed.realmFeedImages.compactMap(localFeedImage),
					timestamp: realmFeed.timestamp
				)
			)
		} else {
			completion(.empty)
		}
	}

	private func insertTo(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let realmFeed = RealmFeed(
			timestamp: timestamp,
			realmFeedImages: feed.map(realmFeedImage)
		)

		do {
			try realm.write {
				realm.add(realmFeed)
			}
			completion(nil)
		} catch {
			completion(error)
		}
	}

	private func realmFeedImage(from localFeedImage: LocalFeedImage) -> RealmFeedImage {
		.init(
			id: localFeedImage.id.uuidString,
			imageDescription: localFeedImage.description,
			location: localFeedImage.location,
			url: localFeedImage.url.absoluteString
		)
	}

	private func localFeedImage(from realmFeedImage: RealmFeedImage) -> LocalFeedImage? {
		guard let id = UUID(uuidString: realmFeedImage.id), let url = URL(string: realmFeedImage.url) else {
			return nil
		}

		return .init(
			id: id,
			description: realmFeedImage.imageDescription,
			location: realmFeedImage.location,
			url: url
		)
	}
}
