---
name: swiftui-design
description: "Design or review SwiftUI interfaces, choose visual directions,
  integrate brand assets, and improve generic iOS or macOS UI."
license: MIT
metadata:
  author: wholiver
  version: "1.0.0"
---

# SwiftUI design

## Environment

- Xcode 16+ with iOS 18+ / macOS 15+ SDK (iOS 26 / macOS 26 adds Liquid Glass;
  see below). Check the project's deployment target and gate newer APIs with
  `#available`.
- SwiftUI framework (not UIKit unless explicitly requested)
- Familiarity with SwiftUI view hierarchy and modifiers

## Principles

### Start from existing context

Before designing any screen, ask:

- Is there an existing design system, UI kit, or Figma file?
- Is there an existing codebase with established visual language?
- Are there brand guidelines or a style guide?

If no context exists, create `brand-spec.md` first using `assets/brand-spec.md`.

### Show hypotheses early

Don't wait for the "perfect" design. Show hypotheses with placeholders early:

- Gray boxes for images are **better** than bad AI-generated SVGs
- System fonts with good spacing > custom fonts with bad spacing
- A rough but honest layout > a polished but generic one

### Offer distinct directions

Always present **2-3 distinct design directions**, not one "final answer." Each
variation should:

- Represent a different design philosophy (e.g., editorial, functional,
  expressive)
- Have a clear rationale for why it works
- Differ in layout or visual approach as well as color

### Use clean placeholders

If you cannot source a real asset (icon, image, illustration):

- Use a clean gray placeholder with clear labeling
- Never use AI-generated SVG clipart
- Never use emoji as icon substitutes in production UI
- For icons, prefer SF Symbols (Apple's built-in icon library)

### Add only useful elements

Before adding a UI element, ask:

- Does this serve the user's goal?
- Can this be combined with something else?
- What happens if I remove it?

Leave whitespace around content.

### Avoid generic visual patterns

The following patterns are prohibited in production UI. Read
`references/anti-ai-slop.md` before choosing visual patterns.

**Prohibited patterns:**

- Purple-to-blue gradient backgrounds
- Emoji as functional icons
- Rounded cards with left-border accent color
- Generic "hero section" with centered text over gradient
- Inter/Roboto as display fonts on Apple platforms
- Neon-on-dark "cyber" aesthetic (#0D1117 base)
- Symmetric 3-column feature grids
- AI-drawn SVG illustrations or CSS silhouettes

**What to do instead:**

- Single warm accent color on neutral background
- SF Symbols for icons, or custom icon set
- Serif display font (e.g., New York, Georgia) for headings
- Restrained information density with enough whitespace
- One distinctive detail per screen
- Real photography or clean placeholders

## Workflow

### Establish brand assets

When building UI for a specific brand, follow this sequence:

1. **Ask.** Request brand guidelines, logo files, color palette, and typography.
   Offer concrete options when they exist.
2. **Search.** If not provided, search the web for "[brand name] brand
   guidelines"
3. **Download.** Get actual asset files (PNG/SVG logos, font files)
4. **Verify.** Confirm colors match official sources (check hex values)
5. **Write `brand-spec.md`.** Document: primary/secondary colors, fonts, logo
   usage rules, spacing tokens

**Quality threshold**: 5 real brand colors, 10 verified design tokens, 2 font
families, 8pt spacing grid.

If no brand exists, create a brand-spec.md with:

- 1 primary accent color (warm, not purple-blue gradient)
- 1 neutral palette (grays with warm undertone)
- 1 display font + 1 body font (SF Pro default is fine)
- 8pt spacing grid

### Choose a design direction

When requirements are vague or the user asks "what style should we use?", follow
this workflow:

#### Understand context

1. Ask the user: What is the app? Who is the user? What platform? Offer iOS,
   macOS, and watchOS as options.
2. Ask the user: Any reference apps or websites they admire? Offer concrete
   options when they exist.
3. Check: Existing design system or brand assets?

#### Recommend directions

Present 3 distinct design philosophies from different schools:

| School | Example directions |
| --------------- | ------------------------------------------- |
| **Information** | Clean data-first, chart-heavy, Bloomberg-style |
| **Editorial** | Magazine layout, serif typography, generous whitespace |
| **Expressive** | Bold color, asymmetric layout, motion-forward |
| **Functional** | Dense utility, monospace accents, minimal decoration |
| **Warm Minimal** | Soft neutrals, rounded shapes, subtle texture |

#### Present visual anchors

For each direction, describe:

- Color palette (3-5 colors with hex values)
- Typography pairing (display + body)
- Layout density (comfortable / compact / spacious)
- Signature detail (one standout element per screen)

#### Confirm the direction

Ask the user, offering the design directions as concrete options. After the
choice, lock in the design system.

### Implement the design

#### Define the design system before coding

Create or confirm these design tokens:

```swift
// Requires: references/swift-extensions.md (Color(hex:) extension)
// DesignTokens.swift
enum DesignTokens {
    // Colors
    static let accent = Color(hex: "E85D3A")      // Warm coral
    // Prefer asset-catalog colors with light/dark variants over fixed hex in production.
    static let background = Color(hex: "FAFAF8")   // Warm white
    static let textPrimary = Color.primary          // Adapts to dark mode
    static let textSecondary = Color.secondary

    // Typography: system fonts scale with Dynamic Type; don't hardcode font names or sizes
    static let display = Font.system(.largeTitle, design: .serif, weight: .bold)  // New York
    static let body = Font.body                                                   // SF Pro

    // Spacing (8pt grid)
    static let spaceXS: CGFloat = 4
    static let spaceS: CGFloat = 8
    static let spaceM: CGFloat = 16
    static let spaceL: CGFloat = 24
    static let spaceXL: CGFloat = 32
    static let spaceXXL: CGFloat = 48

    // Corner radius
    static let radiusS: CGFloat = 8
    static let radiusM: CGFloat = 12
    static let radiusL: CGFloat = 16
}
```

#### Build the layout hierarchy

Follow the layout patterns in `references/layout-patterns.md`:

- Start with the primary content container
- Use `VStack` for vertical flow, `HStack` for horizontal
- Use `LazyVGrid` / `LazyHGrid` for grid layouts
- Use `ScrollView` with `.scrollTargetBehavior(.paging)` for paged content
- Avoid `GeometryReader`; prefer `containerRelativeFrame` (iOS 17+)

#### Apply typography hierarchy

Follow `references/typography-color.md`:

- **Display** (screen titles): Serif font, 28-34pt, bold
- **Heading** (section titles): Sans-serif, 20-24pt, semibold
- **Body** (content text): Sans-serif, 15-17pt, regular
- **Caption** (labels, metadata): Sans-serif, 12-13pt, secondary color

#### Add the signature detail

Give each screen one distinctive detail, such as a custom animation, layout
choice, or use of color.

Examples:

- A custom pull-to-refresh with brand-colored animation
- A card that expands with a spring animation on tap
- A header that uses the brand's display font at an oversized scale
- A subtle parallax effect on scroll

#### Review the design

Before shipping, read `references/design-review.md` and run its five-dimension
review.

## Platform appearance on iOS 26 and macOS 26

- Standard bars, tab bars, toolbars, sheets, and controls get Liquid Glass
  automatically when built with the new SDK. Don't paint opaque backgrounds over
  them or fake the effect with blur.
- Use `.glassEffect()` sparingly, on floating controls above content (not on
  content itself, and not stacked glass on glass). Group neighbors in
  `GlassEffectContainer`.
- Content stays flat and legible; glass belongs to the navigation and control
  layer.
- On older targets fall back to `.regularMaterial`.
- Respect Dynamic Type, Reduce Motion, Reduce Transparency, and Increased
  Contrast; test the largest accessibility text size.

## Common mistakes to avoid

| Mistake                                    | Fix                                                      |
| ------------------------------------------ | -------------------------------------------------------- |
| Using `UIColor` or `NSColor`               | Use `Color` (SwiftUI native)                               |
| `UIScreen.main.bounds` for sizing          | Use `containerRelativeFrame` or geometry-based modifiers |
| Default blue tint everywhere               | Define a custom accent color in design tokens            |
| No spacing system (random padding values)  | Use 8pt grid: 4, 8, 16, 24, 32, 48                       |
| Emoji as icons                             | Use SF Symbols or custom icon assets                     |
| Purple-blue gradient background            | Use solid warm neutrals                                  |
| All content in one giant VStack            | Break into semantic sections with clear hierarchy        |
| No visual hierarchy (everything same size) | Use 3+ type scales (display, heading, body, caption)     |
| Fixed font sizes (`.font(.system(size: 17))`) | Use text styles (`.body`, `.headline`) so Dynamic Type works |
| Ignoring dark mode                         | Define semantic colors that adapt to appearance          |
| Generic "Welcome!" hero section            | Show actual content immediately                          |

## References

| Topic                        | Reference file                      |
| ---------------------------- | ----------------------------------- |
| Visual patterns to avoid  | `references/anti-ai-slop.md`        |
| Layout patterns and grids      | `references/layout-patterns.md`     |
| Typography and color systems   | `references/typography-color.md`    |
| Five-dimension design review    | `references/design-review.md`       |
| Swift extensions for the token example  | `references/swift-extensions.md`    |
| Brand specification template             | `assets/brand-spec.md`          |

## Validation checklist

Before finishing, verify:

- [ ] Design tokens defined (colors, fonts, spacing)
- [ ] No banned AI-slop patterns present
- [ ] Typography has clear hierarchy (3+ scales)
- [ ] Spacing follows 8pt grid
- [ ] Dark mode colors defined and tested
- [ ] One signature detail per screen
- [ ] SF Symbols used for icons (not emoji)
- [ ] Minimum 44×44pt tap targets
- [ ] Layout survives the largest Dynamic Type size and VoiceOver labels exist
  for icon-only buttons
- [ ] Previews cover light, dark, and large text
- [ ] No `GeometryReader` or `UIScreen.main.bounds`
- [ ] Five-dimension review score ≥ 7/10 on all dimensions
