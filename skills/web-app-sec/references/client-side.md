<!-- Changed from https://github.com/BehiSecc/VibeSec-Skill. Apache License 2.0; see LICENSE. -->

# Client-Side
## Client-Side Bugs

### Cross-Site Scripting (XSS)

Every input controllable by the user—whether directly or indirectly—must be sanitized against XSS.

#### Input Sources to Protect

**Direct Inputs:**

- Form fields (email, name, bio, comments, etc.)
- Search queries
- File names during upload
- Rich text editors / WYSIWYG content

**Indirect Inputs:**

- URL parameters and query strings
- URL fragments (hash values)
- HTTP headers used in the application (Referer, User-Agent if displayed)
- Data from third-party APIs displayed to users
- WebSocket messages
- postMessage data from iframes
- LocalStorage/SessionStorage values if rendered

**Often Overlooked:**

- Error messages that reflect user input
- PDF/document generators that accept HTML
- Email templates with user data
- Log viewers in admin panels
- JSON responses rendered as HTML
- SVG file uploads (can contain JavaScript)
- Markdown rendering (if allowing HTML)

#### Protection Strategies

1. **Output Encoding** (Context-Specific)
   - HTML context: HTML entity encode (`<` → `&lt;`)
   - JavaScript context: JavaScript escape
   - URL context: URL encode
   - CSS context: CSS escape
   - Use framework's built-in escaping (React's JSX, Vue's {{ }}, etc.)

2. **Content Security Policy (CSP)**

   ```
   Content-Security-Policy:
     default-src 'self';
     script-src 'self';
     style-src 'self' 'unsafe-inline';
     img-src 'self' data: https:;
     font-src 'self';
     connect-src 'self' https://api.yourdomain.com;
     frame-ancestors 'none';
     base-uri 'self';
     form-action 'self';
   ```

   - Avoid `'unsafe-inline'` and `'unsafe-eval'` for scripts
   - Use nonces or hashes for inline scripts when necessary
   - Report violations: `report-uri /csp-report`

3. **Input Sanitization**
   - Use established libraries (DOMPurify for HTML)
   - Whitelist allowed tags/attributes for rich text
   - Strip or encode dangerous patterns

4. **Additional Headers**
   - `X-Content-Type-Options: nosniff`
   - `X-Frame-Options: DENY` (or use CSP frame-ancestors)

---

### Cross-Site Request Forgery (CSRF)

Every state-changing endpoint must be protected against CSRF attacks.

#### Endpoints Requiring CSRF Protection

**Authenticated Actions:**

- All POST, PUT, PATCH, DELETE requests
- Any GET request that changes state (fix these to use proper HTTP methods)
- File uploads
- Settings changes
- Payment/transaction endpoints

**Pre-Authentication Actions:**

- Login endpoints (prevent login CSRF)
- Signup endpoints
- Password reset request endpoints
- Password change endpoints
- Email/phone verification endpoints
- OAuth callback endpoints

#### Protection Mechanisms

1. **CSRF Tokens**
   - Generate cryptographically random tokens
   - Tie token to user session
   - Validate on every state-changing request
   - Regenerate after login (prevent session fixation combo)

2. **SameSite Cookies**

   ```
   Set-Cookie: session=abc123; SameSite=Strict; Secure; HttpOnly
   ```

   - `Strict`: Cookie never sent cross-site (best security)
   - `Lax`: Cookie sent on top-level navigations (good balance)
   - Always combine with CSRF tokens for defense in depth

3. **Double Submit Cookie Pattern**
   - Send CSRF token in both cookie and request body/header
   - Server validates they match

#### Edge Cases and Common Mistakes

- **Token presence check**: CSRF validation must NOT depend on whether the token is present, always require it
- **Token per form**: Consider unique tokens per form for sensitive operations
- **JSON APIs**: Don't assume JSON content-type prevents CSRF; validate Origin/Referer headers AND use tokens
- **CORS misconfiguration**: Overly permissive CORS can bypass SameSite cookies
- **Subdomains**: CSRF tokens should be scoped because subdomain takeover can lead to CSRF
- **Flash/PDF uploads**: Legacy browser plugins could bypass SameSite
- **GET requests with side effects**: Never perform state changes on GET
- **Token leakage**: Don't include CSRF tokens in URLs
- **Token in URL vs Header**: Prefer custom headers (X-CSRF-Token) over URL parameters

#### Verification Checklist

- [ ] Token is cryptographically random (use secure random generator)
- [ ] Token is tied to user session
- [ ] Token is validated server-side on all state-changing requests
- [ ] Missing token = rejected request
- [ ] Token regenerated on authentication state change
- [ ] SameSite cookie attribute is set
- [ ] Secure and HttpOnly flags on session cookies

---

### Secret Keys and Sensitive Data Exposure

No secrets or sensitive information should be accessible to client-side code.

#### Never Expose in Client-Side Code

**API Keys and Secrets:**

- Third-party API keys (Stripe, AWS, etc.)
- Database connection strings
- JWT signing secrets
- Encryption keys
- OAuth client secrets
- Internal service URLs/credentials

**Sensitive User Data:**

- Full credit card numbers
- Social Security Numbers
- Passwords (even hashed)
- Security questions/answers
- Full phone numbers (mask them: ***-***-1234)
- Sensitive PII that isn't needed for display

**Infrastructure Details:**

- Internal IP addresses
- Database schemas
- Debug information
- Stack traces in production
- Server software versions

#### Where Secrets Hide (Check These!)

- JavaScript bundles (including source maps)
- HTML comments
- Hidden form fields
- Data attributes
- LocalStorage/SessionStorage
- Initial state/hydration data in SSR apps
- Environment variables exposed via build tools (NEXT_PUBLIC_*, REACT_APP_*)

#### Best Practices

1. **Environment Variables**: Store secrets in `.env` files
2. **Server-Side Only**: Make API calls requiring secrets from backend only

---

## Open Redirect

Any endpoint accepting a URL for redirection must be protected against open redirect attacks.

### Protection Strategies

1. **Allowlist Validation**

   ```
   allowed_domains = ['yourdomain.com', 'app.yourdomain.com']

   function isValidRedirect(url):
       parsed = parseUrl(url)
       return parsed.hostname in allowed_domains
   ```

2. **Relative URLs Only**
   - Only accept paths (e.g., `/dashboard`) not full URLs
   - Validate the path starts with `/` and doesn't contain `//`

3. **Indirect References**
   - Use a mapping instead of raw URLs: `?redirect=dashboard` → lookup to `/dashboard`

### Bypass Techniques to Block

| Technique | Example | Why It Works |
| ----------- | --------- | -------------- |
| @ symbol | `https://legit.com@evil.com` | Browser navigates to evil.com with legit.com as username |
| Subdomain abuse | `https://legit.com.evil.com` | evil.com owns the subdomain |
| Protocol tricks | `javascript:alert(1)` | XSS via redirect |
| Double URL encoding | `%252f%252fevil.com` | Decodes to `//evil.com` after double decode |
| Backslash | `https://legit.com\@evil.com` | Some parsers normalize `\` to `/` |
| Null byte | `https://legit.com%00.evil.com` | Some parsers truncate at null |
| Tab/newline | `https://legit.com%09.evil.com` | Whitespace confusion |
| Unicode normalization | `https://legіt.com` (Cyrillic і) | IDN homograph attack |
| Data URLs | `data:text/html,<script>...` | Direct payload execution |
| Protocol-relative | `//evil.com` | Uses current page's protocol |
| Fragment abuse | `https://legit.com#@evil.com` | Parsed differently by different libraries |

### IDN Homograph Attack Protection

- Convert URLs to Punycode before validation
- Consider blocking non-ASCII domains entirely for sensitive redirects

---

### Password Security

#### Password Requirements

- Minimum 8 characters (12+ recommended)
- No maximum length (or very high, e.g., 128 chars)
- Allow all characters including special chars
- Don't require specific character types (let users choose strong passwords)

#### Storage

- Use Argon2id, bcrypt, or scrypt
- Never MD5, SHA1, or plain SHA256

---

