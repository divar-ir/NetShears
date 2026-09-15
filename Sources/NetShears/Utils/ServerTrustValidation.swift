//
//  ServerTrustValidation.swift
//  NetShears
//
//  Created by Pouya Yarandi on 9/13/26.
//

import Foundation
import Security

/// Decides whether a server's certificate chain should be trusted for a given host.
///
/// - Parameters:
///   - trust: The pending evaluation handed over by the TLS stack.
///   - host: The hostname the connection was addressed to. Hostname matching is a
///     separate check from chain trust, so an implementation that ignores this
///     parameter silently disables it.
/// - Returns: `true` if the chain is trusted for `host`.
public typealias ServerTrustEvaluating = (_ trust: SecTrust, _ host: String) -> Bool

/// The single place NetShears decides whether to trust a server.
///
/// NetShears re-issues intercepted requests on its own `URLSession`, which means the
/// host app's own trust configuration — an Alamofire `ServerTrustManager`, a session
/// delegate — is bypassed for any request NetShears handles. This type gives the host
/// app a way to put its policy back in play.
///
/// When no evaluator is installed the default is genuine system evaluation. It is
/// never "accept anything".
public final class ServerTrustValidator {

    public static let shared = ServerTrustValidator()

    private let lock = NSLock()
    private var _evaluator: ServerTrustEvaluating?

    /// Installed by the host app, typically once at startup. Set to `nil` to fall back
    /// to system evaluation.
    public var evaluator: ServerTrustEvaluating? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _evaluator
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _evaluator = newValue
        }
    }

    /// Maps an authentication challenge onto the installed evaluator.
    ///
    /// Challenges that are not server-trust challenges are handed back to the system
    /// untouched — NetShears has no business answering HTTP auth or client-certificate
    /// challenges on the app's behalf.
    func respond(
        to challenge: URLAuthenticationChallenge
    ) -> (disposition: URLSession.AuthChallengeDisposition, credential: URLCredential?) {
        let protectionSpace = challenge.protectionSpace

        guard protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = protectionSpace.serverTrust else {
            return (.performDefaultHandling, nil)
        }

        let isTrusted = (evaluator ?? Self.systemEvaluation)(serverTrust, protectionSpace.host)

        guard isTrusted else {
            return (.cancelAuthenticationChallenge, nil)
        }

        return (.useCredential, URLCredential(trust: serverTrust))
    }

    /// What the system would have done had NetShears not intercepted the request.
    static let systemEvaluation: ServerTrustEvaluating = { trust, host in
        guard SecTrustSetPolicies(trust, SecPolicyCreateSSL(true, host as CFString)) == errSecSuccess else {
            return false
        }
        return SecTrustEvaluateWithError(trust, nil)
    }
}
