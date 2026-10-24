<!-- Changed from https://github.com/BehiSecc/VibeSec-Skill. Apache License 2.0; see LICENSE. -->

# Headers, JWT, and API
## Security Headers Checklist

Include these headers in all responses:

```
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
Content-Security-Policy: [see XSS section]
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Referrer-Policy: strict-origin-when-cross-origin
Cache-Control: no-store (for sensitive pages)
```

---

## JWT Security

JWT misconfigurations can lead to full authentication bypass and token forgery.

### Vulnerabilities

| Vulnerability | Prevention |
| --------------- | ------------ |
| `alg: none` attack | Always verify algorithm server-side, reject `none` |
| Algorithm confusion | Explicitly specify expected algorithm, never derive from token |
| Weak HMAC secrets | Use 256+ bit cryptographically random secrets |
| Missing expiration | Always set `exp` claim |
| Token in localStorage | Store in httpOnly, Secure, SameSite=Strict cookies, never localStorage |

### Secure Implementation

```javascript
// 1. SIGNING
// Always use environment variables for secrets
const secret = process.env.JWT_SECRET;

const token = jwt.sign({
  sub: userId,
  iat: Math.floor(Date.now() / 1000),
  exp: Math.floor(Date.now() / 1000) + (15 * 60), // 15 mins (Short-lived)
  jti: crypto.randomUUID() // Unique ID for revocation/blacklisting
}, secret, {
  algorithm: 'HS256'
});

// 2. SENDING (Cookie Best Practices)
// Protect against XSS and CSRF
res.cookie('token', token, {
  httpOnly: true,
  secure: true,
  sameSite: 'strict'
});

// 3. VERIFYING
// CRITICAL: Whitelist the allowed algorithm
jwt.verify(token, secret, { algorithms: ['HS256'] }, (err, decoded) => {
  if (err) {
    // Handle invalid token
  }
  // Trust the payload
});
```

### JWT Checklist

- [ ] Algorithm explicitly specified on verification (never trust token header)
- [ ] `alg: none` rejected
- [ ] Secret is 256+ bits of random data (not a password or phrase)
- [ ] `exp` claim always set and validated
- [ ] Tokens stored in httpOnly cookies (not localStorage/sessionStorage)
- [ ] Refresh token rotation implemented (old refresh token invalidated on use)

---

## API Security

### Mass Assignment

Accepting unfiltered request bodies can lead to privilege escalation.

```javascript
// VULNERABLE — user can set { role: "admin" } in request body
User.update(req.body)

// SECURE — whitelist allowed fields
const allowed = ['name', 'email', 'avatar']
const updates = pick(req.body, allowed)
User.update(updates)
```

This applies to any ORM/framework — always explicitly define which fields a request can modify.

### GraphQL

| Vulnerability | Prevention |
| :--- | :--- |
| Introspection in production | Disable introspection in production environments. |
| Query depth attack | Implement query depth limiting (e.g., maximum of 10 levels). |
| Query complexity attack | Calculate and enforce strict query cost limits. |
| Batching attack | Limit the number of operations allowed per single request. |

```javascript
const server = new ApolloServer({
  introspection: process.env.NODE_ENV !== 'production',
  validationRules: [
    depthLimit(10),
    costAnalysis({ maximumCost: 1000 })
  ]
})
```

---

