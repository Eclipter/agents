# Other Common Holes

## Command injection

- Never build a shell string from user input. Pass an argument list and no shell: `subprocess.run([...], shell=False)`, `execFile`, `exec.Command`.
- If a shell is unavoidable, allowlist the value (enum, strict regex) before use.
- A leading `-` in a user value becomes an option; put `--` before user-supplied arguments.

```python
# VULNERABLE
os.system(f'convert {filename} out.png')
# SECURE
subprocess.run(['convert', '--', filename, 'out.png'], check=True)
```

## Unsafe deserialization

- Never `pickle.loads`, `yaml.load`, Java `ObjectInputStream`, PHP `unserialize`, or Ruby `Marshal.load` on untrusted data.
- Use JSON with schema validation; for YAML use `yaml.safe_load`.
- Merging user JSON into objects: block `__proto__`, `constructor`, `prototype` keys (prototype pollution).

## CORS

- Never reflect the request `Origin` header back with `Access-Control-Allow-Credentials: true`.
- `Access-Control-Allow-Origin: *` is only for public, cookie-less data.
- Use an exact-match origin allowlist; do not match by `endsWith` or `includes`.

## Rate limiting and abuse

- Limit login, signup, password reset, OTP verification, and any costly endpoint (email/SMS send, search, export, AI calls).
- Key limits by account and IP together; return the same response for existing and unknown accounts (no user enumeration).
- Lock or slow down repeated OTP and reset-token guesses; make tokens single-use, short-lived, and random (128+ bits).

## Race conditions

- Check-then-act on balances, coupons, stock, or invites must be atomic: a DB transaction with a row lock, a unique constraint, or a conditional `UPDATE ... WHERE balance >= :amount`.
- Make payment and webhook handlers idempotent (store the event ID, ignore repeats).

## Webhooks and callbacks

- Verify the provider's signature over the raw body with a constant-time compare; reject old timestamps.
- Never trust the payload alone for money or access changes; re-fetch the object from the provider API when the amount matters.

## Sessions and cookies

- Regenerate the session ID on login and privilege change; invalidate it server-side on logout and password change.
- Cookie flags: `HttpOnly`, `Secure`, `SameSite=Lax` or `Strict`; use the `__Host-` prefix when possible.
- Set an idle and an absolute session timeout.

## Secrets, dependencies, logging

- Secrets live in environment or a secret manager, never in the repo, images, client bundles, or logs. If one leaked, rotate it; deleting the commit is not enough.
- Check `.env`, `.git`, backups, and source maps are not served publicly.
- Use lockfiles; run `npm audit`, `pip-audit`, `cargo audit`, or the ecosystem equivalent; avoid unmaintained packages.
- Do not log passwords, tokens, full card numbers, or session IDs. Strip CR/LF from logged user input (log injection).
- Return generic error messages to clients; keep stack traces and SQL errors server-side. Disable debug mode in production.

## Checklist

- [ ] No user input reaches a shell, `eval`, or a native deserializer
- [ ] CORS uses an exact allowlist
- [ ] Rate limits on auth and costly endpoints
- [ ] Money, stock, and coupon updates are atomic and idempotent
- [ ] Webhook signatures verified
- [ ] Session regenerated on login, cookie flags set
- [ ] No secrets in repo or client; dependencies audited
