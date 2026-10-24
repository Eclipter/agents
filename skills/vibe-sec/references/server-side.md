<!-- Changed from https://github.com/BehiSecc/VibeSec-Skill. Apache License 2.0; see LICENSE. -->

# Server-Side
## Server-Side Bugs

### Server-Side Request Forgery (SSRF)

Any functionality where the server makes requests to URLs provided or influenced by users must be protected.

#### Potential Vulnerable Features

- Webhooks (user provides callback URL)
- URL previews
- PDF generators from URLs
- Image/file fetching from URLs
- Import from URL features
- RSS/feed readers
- API integrations with user-provided endpoints
- Proxy functionality
- HTML to PDF/image converters

#### Protection Strategies

1. **Allowlist Approach** (Preferred)
   - Only allow requests to pre-approved domains
   - Maintain a strict allowlist for integrations

2. **Network Segmentation**
   - Run URL-fetching services in isolated network
   - Block access to internal network, cloud metadata

#### IP and DNS Bypass Techniques to Block

| Technique | Example | Description |
| ----------- | --------- | ------------- |
| Decimal IP | `http://2130706433` | 127.0.0.1 as decimal |
| Octal IP | `http://0177.0.0.1` | Octal representation |
| Hex IP | `http://0x7f.0x0.0x0.0x1` | Hexadecimal |
| IPv6 localhost | `http://[::1]` | IPv6 loopback |
| IPv6 mapped IPv4 | `http://[::ffff:127.0.0.1]` | IPv4-mapped IPv6 |
| Short IPv6 | `http://[::]` | All zeros |
| DNS rebinding | Attacker's DNS returns internal IP | First request resolves to external IP, second to internal |
| CNAME to internal | Attacker domain CNAMEs to internal | DNS points to internal hostname |
| URL parser confusion | `http://attacker.com#@internal` | Different parsing behaviors |
| Redirect chains | External URL redirects to internal | Follow redirects carefully |
| IPv6 scope ID | `http://[fe80::1%25eth0]` | Interface-scoped IPv6 |
| Rare IP formats | `http://127.1` | Shortened IP notation |

#### DNS Rebinding Prevention

1. Resolve DNS before making request
2. Validate resolved IP is not internal
3. Pin the resolved IP for the request (don't re-resolve)
4. Or: Resolve twice with delay, ensure both resolve to same external IP

#### Cloud Metadata Protection

Block access to cloud metadata endpoints:

- AWS: `169.254.169.254`
- GCP: `metadata.google.internal`, `169.254.169.254`, `http://metadata`
- Azure: `169.254.169.254`
- DigitalOcean: `169.254.169.254`

#### Implementation Checklist

- [ ] Validate URL scheme is HTTP/HTTPS only
- [ ] Resolve DNS and validate IP is not private/internal
- [ ] Block cloud metadata IPs explicitly
- [ ] Limit or disable redirect following
- [ ] If following redirects, validate each hop
- [ ] Set timeout on requests
- [ ] Limit response size
- [ ] Use network isolation where possible

---

### Insecure File Upload

File uploads must validate type, content, and size to prevent various attacks.

#### Validation Requirements

**1. File Type Validation**

- Check file extension against allowlist
- Validate magic bytes/file signature match expected type
- Never rely on just one check

**2. File Content Validation**

- Read and verify magic bytes
- For images: attempt to process with image library (detects malformed files)
- For documents: scan for macros, embedded objects
- Check for polyglot files (files valid as multiple types)

**3. File Size Limits**

- Set maximum file size server-side
- Configure web server/proxy limits as well
- Consider per-file-type limits (images smaller than videos)

#### Common Bypasses and Attacks

| Attack | Description | Prevention |
| -------- | ------------- | ------------ |
| Extension bypass | `shell.php.jpg` | Check full extension, use allowlist |
| Null byte | `shell.php%00.jpg` | Sanitize filename, check for null bytes |
| Double extension | `shell.jpg.php` | Only allow single extension |
| MIME type spoofing | Set Content-Type to image/jpeg | Validate magic bytes |
| Magic byte injection | Prepend valid magic bytes to malicious file | Check entire file structure, not just header |
| Polyglot files | File valid as both JPEG and JavaScript | Parse file as expected type, reject if invalid |
| SVG with JavaScript | `<svg onload="alert(1)">` | Sanitize SVG or disallow entirely |
| XXE via file upload | Malicious DOCX, XLSX (which are XML) | Disable external entities in parser |
| ZIP slip | `../../../etc/passwd` in archive | Validate extracted paths |
| ImageMagick exploits | Specially crafted images | Keep ImageMagick updated, use policy.xml |
| Filename injection | `; rm -rf /` in filename | Sanitize filenames, use random names |
| Content-type confusion | Browser MIME sniffing | Set `X-Content-Type-Options: nosniff` |

#### Magic Bytes Reference

| Type | Magic Bytes (hex) |
| ------ | ------------------- |
| JPEG | `FF D8 FF` |
| PNG | `89 50 4E 47 0D 0A 1A 0A` |
| GIF | `47 49 46 38` |
| PDF | `25 50 44 46` |
| ZIP | `50 4B 03 04` |
| DOCX/XLSX | `50 4B 03 04` (ZIP-based) |

#### Secure Upload Handling

1. **Rename files**: Use random UUID names, discard original
2. **Store outside webroot**: Or use separate domain for uploads
3. **Serve with correct headers**:
   - `Content-Disposition: attachment` (forces download)
   - `X-Content-Type-Options: nosniff`
   - `Content-Type` matching actual file type
4. **Use CDN/separate domain**: Isolate uploaded content from main app
5. **Set restrictive permissions**: Uploaded files should not be executable

---

### SQL Injection

SQL injection occurs when user input is incorporated into SQL queries without proper handling.

#### Prevention Methods

**1. Parameterized Queries (Prepared Statements)** — PRIMARY DEFENSE

```sql
-- VULNERABLE
query = "SELECT * FROM users WHERE id = " + userId

-- SECURE
query = "SELECT * FROM users WHERE id = ?"
execute(query, [userId])
```

**2. ORM Usage**

- Use ORM methods that automatically parameterize
- Be cautious with raw query methods in ORMs
- Watch for ORM-specific injection points

**3. Input Validation**

- Validate data types (integer should be integer)
- Whitelist allowed values where applicable
- This is defense-in-depth, not primary defense

#### Injection Points to Watch

- WHERE clauses
- ORDER BY clauses (often overlooked—can't use parameters, must whitelist)
- LIMIT/OFFSET values
- Table and column names (can't parameterize—must whitelist)
- INSERT values
- UPDATE SET values
- IN clauses with dynamic lists
- LIKE patterns (also escape wildcards: %, _)

#### Additional Defenses

- **Least privilege**: Database user should have minimum required permissions
- **Disable dangerous functions**: Like `xp_cmdshell` in SQL Server
- **Error handling**: Never expose SQL errors to users

---

### XML External Entity (XXE)

XXE vulnerabilities occur when XML parsers process external entity references in user-supplied XML.

#### Vulnerable Scenarios

**Direct XML Input:**

- SOAP APIs
- XML-RPC
- XML file uploads
- Configuration file parsing
- RSS/Atom feed processing

**Indirect XML:**

- JSON/other format converted to XML server-side
- Office documents (DOCX, XLSX, PPTX are ZIP with XML)
- SVG files (XML-based)
- SAML assertions
- PDF with XFA forms

#### Prevention by Language/Parser

**Java:**

```java
DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
dbf.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
dbf.setFeature("http://xml.org/sax/features/external-general-entities", false);
dbf.setFeature("http://xml.org/sax/features/external-parameter-entities", false);
dbf.setExpandEntityReferences(false);
```

**Python (lxml):**

```python
from lxml import etree
parser = etree.XMLParser(resolve_entities=False, no_network=True)
# Or use defusedxml library
```

**PHP:**

```php
libxml_disable_entity_loader(true);
// Or use XMLReader with proper settings
```

**Node.js:**

```javascript
// Use libraries that disable DTD processing by default
// If using libxmljs, set { noent: false, dtdload: false }
```

**.NET:**

```csharp
XmlReaderSettings settings = new XmlReaderSettings();
settings.DtdProcessing = DtdProcessing.Prohibit;
settings.XmlResolver = null;
```

#### XXE Prevention Checklist

- [ ] Disable DTD processing entirely if possible
- [ ] Disable external entity resolution
- [ ] Disable external DTD loading
- [ ] Disable XInclude processing
- [ ] Use latest patched XML parser versions
- [ ] Validate/sanitize XML before parsing if DTD needed
- [ ] Consider using JSON instead of XML where possible

---

### Path Traversal

Path traversal vulnerabilities occur when user input controls file paths, allowing access to files outside intended directories.

#### Vulnerable Patterns

```python
# VULNERABLE
file_path = "/uploads/" + user_input
file_path = base_dir + request.params['file']
template = "templates/" + user_provided_template
```

#### Prevention Strategies

**1. Avoid User Input in Paths**

```python
# Instead of using user input directly
# Use indirect references
files = {'report': '/reports/q1.pdf', 'invoice': '/invoices/2024.pdf'}
file_path = files.get(user_input)  # Returns None if invalid
```

**2. Canonicalization and Validation**

```python
import os

def safe_join(base_directory, user_path):
    # Ensure base is absolute and normalized
    base = os.path.abspath(os.path.realpath(base_directory))

    # Join and then resolve the result
    target = os.path.abspath(os.path.realpath(os.path.join(base, user_path)))

    # Ensure the commonpath is the base directory
    if os.path.commonpath([base, target]) != base:
        raise ValueError("Error!")

    return target
```

**3. Input Sanitization**

- Remove or reject `..` sequences
- Remove or reject absolute path indicators (`/`, `C:`)
- Whitelist allowed characters (alphanumeric, dash, underscore)
- Validate file extension if applicable

#### Path Traversal Checklist

- [ ] Never use user input directly in file paths
- [ ] Canonicalize paths and validate against base directory
- [ ] Restrict file extensions if applicable
- [ ] Test with various encoding and bypass techniques

---

