---
name: lighthouse-4x100
description: Audit and systematically optimize any Next.js / React web application to achieve 100/100 across all 4 Lighthouse categories — Performance (95-100), Accessibility (100), Best Practices (100), and SEO (100). Automates diagnosis, zero-delay LCP paint, mobile touch bypass for smooth-scroll engines, contrast calculations, and WCAG AA/AAA compliance.
---

# Lighthouse 4x100 — Complete Performance, A11y, Best Practices & SEO Playbook

A battle-tested engineering blueprint to take any modern Next.js / React web application to **100/100 across all 4 Lighthouse categories**:
1. **Performance:** `95–100 / 100` (Sub-second LCP, 0ms TBT, 0 CLS)
2. **Accessibility:** `100 / 100` (Zero contrast violations, WCAG 2.5.3 Label in Name, valid ARIA semantics)
3. **Best Practices:** `100 / 100` (Zero console warnings, modern image compression, secure headers)
4. **SEO:** `100 / 100` (Origin-portable canonical mapping, crawlable anchors, descriptive link texts)

---

## Quick Start (Automated Driver)

Run the deterministic headless Lighthouse audit harness against your production build:

```bash
# 1. Build and launch local production server
npm run build && npm run start

# 2. Run the automated diagnostic driver
node .claude/skills/lighthouse-4x100/scripts/lighthouse-runner.mjs http://localhost:3000
```

The script automatically runs headless Lighthouse with extensions and caching disabled, outputs the 4 category scores, and prints the exact failing DOM selectors, snippets, and actionable fixes.

---

## Core Pillars & Battle-Tested Rules

### 1. Performance Optimization (95–100 / 100)

#### 1.1 Zero-Delay LCP (Largest Contentful Paint < 0.9s)
- **Problem:** Wrapping the Hero `<h1>` or subheadline in `overflow-hidden` for line-reveals, or setting `opacity: 0`, `visibility: hidden`, or GSAP `.from({ yPercent: 100 })` on mount hides the LCP text from paint on Frame 0, delaying LCP by 2–4 seconds.
- **Rule:** The Hero `<h1>` and subheadline MUST render at `opacity: 1` immediately in initial SSR HTML.
- **Fix:** Remove initial `opacity-0` or `overflow-hidden` line masks from the LCP element. On mount, only animate subtle transforms (`y: 10` to `0`) on decorative badge or CTA elements, or gate GSAP mount timelines to desktop pointer:
  ```tsx
  const mm = gsap.matchMedia();
  mm.add('(prefers-reduced-motion: no-preference) and (pointer: fine)', () => {
    // Only run entrance animations on desktop pointer
    gsap.from('.hero-badge', { y: -10, duration: 0.5 });
  });
  ```

#### 1.2 Bypass Lenis / Smooth-Scroll on Mobile Touch Devices
- **Problem:** Lighthouse emulates a mobile device with coarse pointer and 4x CPU throttle. Running `Lenis` + `gsap.ticker` continuous `requestAnimationFrame` loops on mobile burns main-thread CPU time during initial hydration, inflating Total Blocking Time (TBT) by 1,500–3,000ms. Mobile devices already feature native 120Hz momentum scrolling.
- **Rule:** Never run virtual smooth-scroll libraries on touch/mobile devices during page load.
- **Fix in `SmoothScrollProvider.tsx`:**
  ```tsx
  const isDesktopPointer =
    typeof window.matchMedia === 'function' &&
    window.matchMedia('(pointer: fine)').matches;

  // Bypass on mobile/touch; defer on desktop until wheel or idle
  if (isDesktopPointer && !prefersReducedMotion) {
    window.addEventListener('wheel', initLenis, { once: true, passive: true });
    if ('requestIdleCallback' in window) {
      window.requestIdleCallback(initLenis, { timeout: 2000 });
    }
  }
  ```

#### 1.3 Defer Canvas / WebGL Animation Loops Until Idle
- **Problem:** Initializing continuous 60 FPS `requestAnimationFrame` raycasting or particle loops in Hero or below-the-fold canvas elements immediately on mount locks the main thread during hydration.
- **Rule:** Render **one static frame immediately** so the visual appears on paint with zero pop-in, but defer the continuous animation loop to `requestIdleCallback` (or first interaction):
  ```tsx
  // Render single initial frame immediately
  render();

  // Defer continuous loop until idle or first pointer/scroll
  const startLoop = () => {
    if (loopStarted) return;
    loopStarted = true;
    animId = requestAnimationFrame(animate);
  };

  if ('requestIdleCallback' in window) {
    window.requestIdleCallback(startLoop, { timeout: 1500 });
  } else {
    setTimeout(startLoop, 1500);
  }
  window.addEventListener('scroll', startLoop, { passive: true, once: true });
  ```

#### 1.4 Code-Split Below-the-Fold Sections (Next.js 15 RSC)
- Keep above-the-fold sections (`Navbar`, `HeroSection`, `MetricsRail`) statically imported for instant SSR paint.
- Use `next/dynamic` with `{ ssr: true }` for heavy interactive components below the fold (e.g. 3D configurators, complex calculators, accordion groups) to split their client JavaScript into separate chunks rather than bundling them into one giant blocking root bundle.

#### 1.5 Eliminate Render-Blocking Stylesheets
- Remove external `@import url(...)` rules inside CSS files (e.g., `globals.css`).
- Use `<link rel="preconnect">` and `<link rel="dns-prefetch">` in the document `<head>` for CDN font origins.

---

### 2. Accessibility Optimization (100 / 100)

#### 2.1 WCAG 2.5.3: Label in Name Parity
- **Rule:** If an element has visible text, its accessible name (`aria-label`) MUST CONTAIN or START WITH the visible text. Never use an `aria-label` that contradicts the visible wording.
- **Bad:** Button visible text is `"Run Pipeline"` with `aria-label="Trigger automated CI/CD deployment pipeline"`.
- **Good:** Remove redundant `aria-label` when visible text is already descriptive, or prefix it:
  ```tsx
  <button type="button">Run Pipeline</button>
  // Or:
  <button type="button" aria-label="Run Pipeline — Trigger automated CI/CD deployment pipeline">
  ```

#### 2.2 Color Contrast (WCAG AA 4.5:1 / AAA 7:1)
- **Gradient Buttons & Badges:** On vibrant solar/orange gradients (`#FDA136` / `#F25421`), white text (`#EDEDF3`) fails WCAG AA (only ~2:1 contrast). Use deep midnight ink (`#080612` text) on amber backgrounds (yields **8.8:1 AAA contrast**). On dark crimson backgrounds (`#A61253`), use pure white text (`#FFFFFF`, yields **7.8:1 AAA contrast**).
- **Muted Telemetry Labels:** Avoid `#6E6A82` (3.6:1 fail on dark backgrounds). Use `#9490A8` (yields **5.8:1 WCAG AA pass**).
- **Verification Tool:**
  ```bash
  node .claude/skills/lighthouse-4x100/scripts/contrast-calculator.mjs "#080612" "#FDA136"
  ```

#### 2.3 Form Elements & Input Sliders
- Every `<input type="range">`, `<input type="checkbox">`, and `<select>` MUST have an accessible name via explicit `aria-label` or `<label htmlFor="...">`.

#### 2.4 Strict Heading Progression
- Maintain sequential heading order: `<h1>` in Hero → `<h2>` in section headers → `<h3>` in cards. Never skip from `<h2>` directly to `<h4>`.
- If a section has no visual title, add a screen-reader heading:
  ```tsx
  <h2 className="sr-only">Key Performance Metrics</h2>
  ```

#### 2.5 Dialog Semantics
- Ensure any popups or modals declare `role="dialog"`, `aria-modal="true"`, and `aria-labelledby="[id]"`.

---

### 3. Best Practices (100 / 100)

- **Zero Console Errors / Warnings:** Fix any React hydration mismatches, missing key props, or unhandled errors.
- **Modern Image Formats:** Configure `next.config.ts`:
  ```ts
  images: {
    formats: ['image/avif', 'image/webp'],
  }
  ```
- **Explicit Dimensions:** Prevent layout shift by providing `fill` + `sizes` or explicit `width` and `height` attributes on all `<Image>` elements.

---

### 4. Search Engine Optimization (SEO 100 / 100)

#### 4.1 Portable Canonical & Sitemap Origin
- **Problem:** Hardcoding a production domain (`https://example.com`) in `metadataBase` causes Chrome DevTools Lighthouse to fail the `canonical` audit when testing locally on `localhost` ("Canonical points to a different origin").
- **Fix:** Use portable origin resolution:
  ```ts
  const siteUrl = process.env.NEXT_PUBLIC_SITE_URL || 'http://localhost:3000';

  export const metadata: Metadata = {
    metadataBase: new URL(siteUrl),
    alternates: {
      canonical: '/',
    },
  };
  ```

#### 4.2 Crawlable Anchors (`crawlable-anchors`)
- Never use dummy `href="#"` or `<a>` tags with `onClick={(e) => { e.preventDefault(); ... }}` for JavaScript actions (such as opening modals or copying text). Use `<button type="button">` for UI actions and real anchor targets (`href="#estimate"`, `href="#work"`) for navigation.

#### 4.3 Descriptive Link Text (`link-text`)
- Avoid bare generic links like `"VISIT"` or `"Learn more"`. Provide descriptive text:
  ```tsx
  <a href={link.href} aria-label={`View live deployment for ${project.title}`}>
    <span>VISIT</span>
  </a>
  ```

---

## Verification & Audit Commands

```bash
# Test unit and integration suites
npm test

# Build production bundle
npm run build

# Start production server
npm run start

# Run automated Lighthouse 4x100 scorecard
node .claude/skills/lighthouse-4x100/scripts/lighthouse-runner.mjs http://localhost:3000
```
