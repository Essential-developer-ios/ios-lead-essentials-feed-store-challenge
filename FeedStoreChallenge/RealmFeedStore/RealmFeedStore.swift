import Foundation
import RealmSwift

public final class RealmFeedStore: FeedStore {
	public typealias Configuration = Realm.Configuration

	private let realm: Realm

	public init(configuration: Configuration = .defaultConfiguration) throws {
		self.realm = try Realm(configuration: configuration)
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
		let realmFeed = RealmFeed(
			timestamp: timestamp,
			realmFeedImages: feed.map(realmFeedImage)
		)

		do {
			try realm.write {
				realm.deleteAll()
				realm.add(realmFeed)
			}
			completion(nil)
		} catch {
			completion(error)
		}
	}

	public func retrieve(completion: @escaping RetrievalCompletion) {
		guard let realmFeed = realm.objects(RealmFeed.self).first, !realmFeed.realmFeedImages.isEmpty else {
			return completion(.empty)
		}

		completion(
			.found(
				feed: realmFeed.realmFeedImages.compactMap(localFeedImage),
				timestamp: realmFeed.timestamp
			)
		)
	}

	private func realmFeedImage(from localFeedImage: LocalFeedImage) -> RealmFeedImage {
		.init(
			id: localFeedImage.id,
			imageDescription: localFeedImage.description,
			location: localFeedImage.location,
			url: localFeedImage.url
		)
	}

	private func localFeedImage(from realmFeedImage: RealmFeedImage) -> LocalFeedImage? {
		guard let id = realmFeedImage.id, let url = realmFeedImage.url else {
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
