import Foundation
import RealmSwift

final class RealmFeedImage: Object {
	@objc dynamic var id: String = ""
	@objc dynamic var imageDescription: String?
	@objc dynamic var location: String?
	@objc dynamic var url: String = ""
}

final class RealmFeed: Object {
	@objc dynamic var timestamp: Date = .init()
	var feedImages: List<RealmFeedImage> = .init()
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
				completion(nil)
			}
		} catch {
			completion(error)
		}
	}

	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let realmFeedImages = List<RealmFeedImage>()
		feed.forEach { realmFeedImages.append(realmFeedImage(from: $0)) }

		let realmFeed = RealmFeed()
		realmFeed.timestamp = timestamp
		realmFeed.feedImages = realmFeedImages

		do {
			try realm.write {
				realm.add(realmFeed)
				completion(nil)
			}
		} catch {
			completion(error)
		}
	}

	public func retrieve(completion: @escaping RetrievalCompletion) {
		if let realmFeed = realm.objects(RealmFeed.self).first, !realmFeed.feedImages.isEmpty {
			completion(
				.found(
					feed: realmFeed.feedImages.map(localFeedImage(from:)),
					timestamp: realmFeed.timestamp
				)
			)
		} else {
			completion(.empty)
		}
	}

	private func realmFeedImage(from localFeedImage: LocalFeedImage) -> RealmFeedImage {
		let realmFeedImage = RealmFeedImage()
		realmFeedImage.id = localFeedImage.id.uuidString
		realmFeedImage.imageDescription = localFeedImage.description
		realmFeedImage.location = localFeedImage.location
		realmFeedImage.url = localFeedImage.url.absoluteString
		return realmFeedImage
	}

	private func localFeedImage(from realmFeedImage: RealmFeedImage) -> LocalFeedImage {
		.init(
			id: UUID(uuidString: realmFeedImage.id)!,
			description: realmFeedImage.imageDescription,
			location: realmFeedImage.location,
			url: URL(string: realmFeedImage.url)!
		)
	}
}
