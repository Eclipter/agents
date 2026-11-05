---
name: glassmorphism
description: "Create frosted glass effects, transparent overlays, and layered glass UI with blur, tint, borders, and colored shadows. Use when building glassmorphism, backdrop-blur, or frosted-glass interfaces."
---

# Glassmorphism

Examples use Tailwind. For plain CSS or SwiftUI, apply the same recipe: blur + translucent tint + thin light border + soft shadow. In SwiftUI use `.background(.ultraThinMaterial)` (or `.regularMaterial`, `.thickMaterial`) instead of hand-tuned blur.

## Rules

1. **Needs something behind it.** Glass over a flat color looks like a gray box. Put a gradient, image, or colored shapes behind it.
2. **`backdrop-blur-*` plus a semi-transparent background**: `bg-white/10`, `bg-black/40`.
3. **Thin light border** (`border-white/20`) and an optional inner top highlight to fake an edge.
4. **Soft shadow for depth**: `shadow-xl shadow-primary/10`.
5. **Define light and dark variants.**
6. **Text stays readable**: contrast ≥ 4.5:1 against the worst-case background behind the glass. Raise the tint opacity before reducing text weight.
7. **Few glass layers**: glass on primary surfaces only (cards, modals, nav). Don't glass everything.

## Quick reference

### Base

```tsx
className="bg-white/10 backdrop-blur-xl border border-white/20 rounded-2xl"
```

### Safari support

Safari needs the prefixed property in plain CSS (Tailwind adds it for you):

```css
.glass {
  background: rgb(255 255 255 / 0.1);
  -webkit-backdrop-filter: blur(24px) saturate(150%);
  backdrop-filter: blur(24px) saturate(150%);
  border: 1px solid rgb(255 255 255 / 0.2);
}
```

### Edge highlight and colored shadow

```tsx
className="bg-white/10 backdrop-blur-xl border border-white/20 shadow-xl shadow-primary/10 shadow-[inset_0_1px_0_0_rgb(255_255_255/0.3)]"
```

### Blur levels

| Level | Class | Use |
| ------- | ------- | ----- |
| Subtle | `backdrop-blur-sm` | Overlays on clean backgrounds |
| Medium | `backdrop-blur-md` | Cards, modals |
| Strong | `backdrop-blur-xl` | Primary surfaces |
| Maximum | `backdrop-blur-3xl` | Hero sections |

### Layered stack

```tsx
<div className="relative">
  <div className="absolute inset-0 bg-white/5 backdrop-blur-3xl rounded-3xl" />
  <div className="absolute inset-2 bg-white/10 backdrop-blur-xl rounded-2xl" />
  <div className="relative bg-white/20 backdrop-blur-md rounded-xl p-6">
    {children}
  </div>
</div>
```

### Dark mode

```tsx
className="bg-white/80 backdrop-blur-xl dark:bg-black/40 border-black/10 dark:border-white/20"
```

Light mode needs a higher tint opacity (`/60` to `/80`) than dark mode, or text washes out.

### Accessibility and performance

```tsx
// Fallback for users who reduce transparency and for browsers without blur
className="bg-white/10 backdrop-blur-xl contrast-more:bg-white/90 contrast-more:backdrop-blur-none supports-[not(backdrop-filter:blur(1px))]:bg-white/90"
```

- Blur is expensive: avoid it on large scrolling lists, many stacked layers, or animated elements; animate `opacity`/`transform`, not the blur radius.
- Keep blur radius ≤ 24px on mobile.

## Checklist

- [ ] Colorful or image background behind the glass
- [ ] `backdrop-blur-*` and semi-transparent background present
- [ ] Subtle border
- [ ] Text contrast ≥ 4.5:1 on light and dark backgrounds
- [ ] Light and dark variants defined
- [ ] Fallback for no `backdrop-filter` and reduced transparency
