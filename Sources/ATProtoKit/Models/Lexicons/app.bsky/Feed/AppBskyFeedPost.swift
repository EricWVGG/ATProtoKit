//
//  AppBskyFeedPost.swift
//
//
//  Created by Christopher Jr Riley on 2024-05-19.
//

import Foundation

extension AppBskyLexicon.Feed {

    /// The record model definition for a post record.
    ///
    /// - Note: According to the AT Protocol specifications: "Record containing a Bluesky post."
    ///
    /// - SeeAlso: This is based on the [`app.bsky.feed.post`][github] lexicon.
    ///
    /// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/feed/post.json
    public struct PostRecord: ATRecordProtocol, Sendable {

        /// The identifier of the lexicon.
        ///
        /// - Warning: The value must not change.
        public static let type: String = "app.bsky.feed.post"

        /// The text contained in the post.
        ///
        /// - Note: According to the AT Protocol specifications: "The primary post content. May be
        /// an empty string, if there are embeds."
        ///
        /// - Important: Current maximum length is 300 characters. This library will automatically
        /// truncate the `String` to the maximum length if it does go over the limit.
        public let text: String

        /// An array of facets contained in the post's text. Optional.
        ///
        /// - Note: According to the AT Protocol specifications: "Annotations of text (mentions, URLs,
        /// hashtags, etc)"
        public var facets: [AppBskyLexicon.RichText.Facet]?

        /// The references to posts when replying. Optional.
        public var reply: ReplyReference?

        /// The embed of the post. Optional.
        public var embed: ATUnion.PostEmbedUnion?

        /// An array of languages the post text contains. Optional.
        ///
        /// - Note: According to the AT Protocol specifications: "Indicates human language of post
        /// primary text content."
        ///
        /// - Important: Current maximum length is 3 languages. This library will automatically
        /// truncate the `Array` to the maximum number of items if it does go over the limit.
        public var languages: [String]?

        /// An array of user-defined labels. Optional.
        ///
        /// - Note: According to the AT Protocol specifications: "Self-label values for this post.
        /// Effectively content warnings."
        public var labels: ATUnion.PostSelfLabelsUnion?

        /// An array of user-defined tags. Optional.
        ///
        /// - Note: According to the AT Protocol specifications: "Additional hashtags, in addition to
        /// any included in post text and facets."
        ///
        /// - Important: Current maximum length is 8 tags. Current maximum length of the tag name
        /// is 64 characters. This library will automatically truncate the `Array`and `String`
        /// respectively to the maximum length if it does go over the limit.
        public var tags: [String]?

        /// The date the post was created.
        ///
        /// - Note: According to the AT Protocol specifications: "Client-declared timestamp when this
        /// post was originally created."
        public let createdAt: Date

        public init(text: String, facets: [AppBskyLexicon.RichText.Facet]?, reply: ReplyReference?, embed: ATUnion.PostEmbedUnion?, languages: [String]?,
                    labels: ATUnion.PostSelfLabelsUnion?, tags: [String]?, createdAt: Date) {
            self.text = text
            self.facets = facets
            self.reply = reply
            self.embed = embed
            self.languages = languages
            self.labels = labels
            self.tags = tags
            self.createdAt = createdAt
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.text = try container.decode(String.self, forKey: .text)
            self.facets = try container.decodeIfPresent([AppBskyLexicon.RichText.Facet].self, forKey: .facets)
            self.reply = try container.decodeIfPresent(ReplyReference.self, forKey: .reply)
            self.embed = try container.decodeIfPresent(ATUnion.PostEmbedUnion.self, forKey: .embed)
            self.languages = try container.decodeIfPresent([String].self, forKey: .languages)
            self.labels = try container.decodeIfPresent(ATUnion.PostSelfLabelsUnion.self, forKey: .labels)
            self.tags = try container.decodeIfPresent([String].self, forKey: .tags)
            self.createdAt = try container.decodeDate(forKey: .createdAt)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(AppBskyLexicon.Feed.PostRecord.type, forKey: .type)
            try container.encode(self.text, forKey: .text)
            try container.truncatedEncode(self.text, forKey: .text, upToCharacterLength: 300)
            try container.encodeIfPresent(self.facets, forKey: .facets)
            try container.encodeIfPresent(self.reply, forKey: .reply)
            try container.encodeIfPresent(self.embed, forKey: .embed)
            try container.truncatedEncodeIfPresent(self.languages, forKey: .languages, upToArrayLength: 3)
            try container.encodeIfPresent(self.labels, forKey: .labels)
            try container.truncatedEncodeIfPresent(self.tags, forKey: .tags, upToCharacterLength: 64, upToArrayLength: 8)
            try container.encodeDate(self.createdAt, forKey: .createdAt)
        }

        enum CodingKeys: String, CodingKey {
            case type = "$type"
            case text
            case entities
            case facets
            case reply
            case embed
            case languages = "langs"
            case labels
            case tags
            case createdAt
        }

        // Enums
        /// A data model for a reply reference definition.
        ///
        /// - SeeAlso: This is based on the [`app.bsky.feed.post`][github] lexicon.
        ///
        /// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/feed/post.json
        public struct ReplyReference: Sendable, Codable, Equatable, Hashable {

            /// The original post of the thread.
            public let root: ComAtprotoLexicon.Repository.StrongReference

            /// The direct post that the user's post is replying to.
            ///
            /// - Note: If `parent` and `root` are identical, the post is a direct reply to the original
            /// post of the thread.
            public let parent: ComAtprotoLexicon.Repository.StrongReference
        }
    }
}
