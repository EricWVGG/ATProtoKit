//
//  SearchActors.swift
//
//
//  Created by Christopher Jr Riley on 2024-02-23.
//

import Foundation

extension ATProtoKit {

    /// Looks for user profiles (actors) matching the search term.
    /// 
    /// This will search for the display names, descriptions, and handles within the user profiles.
    /// However, this API call can only return results of a matching handle. If you want search
    /// suggestion (where it returns results based on a partial term instead of the exact term),
    /// a different method is needed.
    ///
    /// - Note: According to the AT Protocol specifications: "Find actors (profiles) matching
    /// search criteria. Does not require auth."
    ///
    /// - SeeAlso: This is based on the [`app.bsky.actor.searchActors`][github] lexicon.
    ///
    /// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/actor/searchActors.json
    ///
    /// - Parameters:
    ///   - query: The string used against a list of actors.
    ///   - limit: The number of suggested users to follow. Optional. Defaults to `25`.
    ///   Can only choose between 1 and 100.
    ///   - cursor: The mark used to indicate the starting point for the next set
    ///   of results. Optional.
    ///   - shouldAuthenticate: Indicates whether the method will use the access token when
    ///   sending the request. Defaults to `true`.
    /// - Returns: An array of actors, with an optional cursor to expand the array.
    ///
    /// - Throws: An ``ATProtoError``-conforming error type, depending on the issue. Go to
    /// ``ATAPIError`` and ``ATRequestPrepareError`` for more details.
    public func searchActors(
        matching query: String,
        limit: Int? = 25,
        cursor: String? = nil,
        shouldAuthenticate: Bool = true
    ) async throws -> AppBskyLexicon.Actor.SearchActorsOutput {
        let authorizationValue = await prepareAuthorizationValue(
            shouldAuthenticate: shouldAuthenticate
        )

        guard self.pdsURL != "" else {
            throw ATRequestPrepareError.emptyPDSURL
        }
        
        var requestURL: URL? = nil
        
        if let sessionURL = authorizationValue != nil ? try await self.getUserSession()?.serviceEndpoint.absoluteString : self.pdsURL {
            requestURL = URL(string: "\(sessionURL)/xrpc/app.bsky.actor.searchActors")
        } else {
            guard let session = try await self.getUserSession(),
                  let keychain = sessionConfiguration?.keychainProtocol else {
                throw ATRequestPrepareError.missingActiveSession
            }

            let accessToken = try await keychain.retrieveAccessToken()
            let sessionURL = session.serviceEndpoint.absoluteString

            requestURL = URL(string: "\(sessionURL)/xrpc/app.bsky.actor.searchActors")
        }

        guard let requestURL = requestURL else {
            throw ATRequestPrepareError.invalidRequestURL
        }

        // Make sure limit is between 1 and 100. If no value is given, set it to 25.
        let finalLimit = max(1, min(limit ?? 25, 100))

        var queryItems = [
            ("q", query),
            ("limit", "\(finalLimit)")
        ]

        if let cursor {
            queryItems.append(("cursor", cursor))
        }

        let queryURL: URL

        do {
            queryURL = try APIClientService.setQueryItems(
                for: requestURL,
                with: queryItems
            )

            let request = await APIClientService.createRequest(
                forRequest: queryURL,
                andMethod: .get,
                acceptValue: "application/json",
                authorizationValue: authorizationValue
            )
            let response = try await APIClientService.shared.sendRequest(
                request,
                decodeTo: AppBskyLexicon.Actor.SearchActorsOutput.self
            )

            return response
        } catch {
            throw error
        }
    }
}
