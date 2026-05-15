---
name: ButlerX
colors:
  surface: '#f9f9ff'
  surface-dim: '#d8d9e3'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3fd'
  surface-container: '#ecedf7'
  surface-container-high: '#e6e8f2'
  surface-container-highest: '#e0e2ec'
  on-surface: '#191c23'
  on-surface-variant: '#414754'
  inverse-surface: '#2d3038'
  inverse-on-surface: '#eff0fa'
  outline: '#727785'
  outline-variant: '#c1c6d6'
  surface-tint: '#005bc0'
  primary: '#005bbf'
  on-primary: '#ffffff'
  primary-container: '#1a73e8'
  on-primary-container: '#ffffff'
  inverse-primary: '#adc7ff'
  secondary: '#006b5c'
  on-secondary: '#ffffff'
  secondary-container: '#68fadd'
  on-secondary-container: '#007261'
  tertiary: '#6833ea'
  on-tertiary: '#ffffff'
  tertiary-container: '#8155ff'
  on-tertiary-container: '#060021'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#adc7ff'
  on-primary-fixed: '#001a41'
  on-primary-fixed-variant: '#004493'
  secondary-fixed: '#68fadd'
  secondary-fixed-dim: '#44ddc1'
  on-secondary-fixed: '#00201a'
  on-secondary-fixed-variant: '#005145'
  tertiary-fixed: '#e8deff'
  tertiary-fixed-dim: '#cdbdff'
  on-tertiary-fixed: '#20005f'
  on-tertiary-fixed-variant: '#4f00d0'
  background: '#f9f9ff'
  on-background: '#191c23'
  surface-variant: '#e0e2ec'
typography:
  hero-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.02em
  hero-lg-mobile:
    fontFamily: Be Vietnam Pro
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
    letterSpacing: -0.02em
  title-md:
    fontFamily: Be Vietnam Pro
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-sm:
    fontFamily: Be Vietnam Pro
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-md:
    fontFamily: Be Vietnam Pro
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Be Vietnam Pro
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 22px
  caption:
    fontFamily: Be Vietnam Pro
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-xs:
    fontFamily: Be Vietnam Pro
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  touch-target-min: 48px
  margin-page: 20px
  gutter-grid: 16px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 24px
---

## Brand & Style
The design system for ButlerX embodies "Soft Futurism"—a harmonious blend of high-technology precision and the welcoming hospitality inherent in Vietnamese culture. The visual language moves away from the sterile, cold aesthetics often associated with AI, opting instead for a "Vietnamese warmth" achieved through organic layering and warm-tinted neutrals.

The experience is centered around a tactile digital assistant that feels present yet unobtrusive. We employ **Glassmorphism** and **Soft-Glow** effects to simulate depth and energy, suggesting that the AI is a living light source behind the interface. The interface prioritizes clarity and high-contrast accessibility to ensure the assistant is usable across all lighting conditions and by diverse age groups.

## Colors
The palette is anchored by a "Humanist Blue" and "Vitality Teal." To avoid the clinical feel of standard tech apps, the neutral base is a warm-toned off-white (Light) or a deep charcoal with a hint of amber (Dark), ensuring the UI feels grounded.

**Core Palettes:**
- **Primary (Action):** Used for the main AI interaction states and primary buttons.
- **Secondary (Success/Energy):** Used for voice activity indicators and positive feedback.
- **Tertiary (Wisdom):** Used for specialized features like smart home or scheduling.
- **Glows:** Accent colors should be applied as soft-diffusion glows (20-30% opacity) behind active elements to represent the AI's "energy."

## Typography
This design system uses **Be Vietnam Pro** exclusively. It is a font designed specifically for the Vietnamese language, handling tone marks with exceptional legibility and aesthetic balance.

- **Scale:** Use `hero-lg` for the primary AI greeting or "speaking" text. Use `title` levels for card headers and categorized lists. 
- **Readability:** Maintain generous line heights (1.5x for body) to ensure Vietnamese diacritics do not clash between lines. 
- **Visual Weight:** Headlines use a semi-bold weight (600) to stand out against the soft, glowing backgrounds.

## Layout & Spacing
The layout follows a **Fluid Grid** model designed for mobile-first interaction. 

- **The Voice Zone:** The bottom 30% of the screen is reserved for the AI "Orb" and voice interaction triggers. 
- **Safe Areas:** A 20px horizontal margin is maintained globally to prevent content from hitting the screen edges.
- **Touch Targets:** No interactive element (buttons, chips, icons) should be smaller than 48px in height or width, ensuring accessibility for all users during on-the-go voice interaction.
- **Rhythm:** We use an 8px base grid for vertical stacking, creating a predictable and clean hierarchy.

## Elevation & Depth
Depth in this design system is achieved through **Layering and Luminosity** rather than harsh shadows.

- **Surface Tiers:** Background is Tier 0. Standard cards are Tier 1 (using a subtle 5% white/black tint). Active AI dialogs are Tier 2 (Glassmorphism).
- **Glassmorphism:** Use a backdrop-blur (20px to 40px) with a semi-transparent fill (80% opacity) for overlays and navigation bars.
- **The Glow:** The primary elevation indicator is a "Soft Glow" border. Instead of a drop shadow, active elements use a 1px inner stroke and a diffuse outer bloom matching the Primary Blue or Secondary Teal colors.
- **Subtle Shadows:** For non-AI elements, use ultra-soft, low-opacity (10%) shadows with a large blur radius to mimic ambient lighting.

## Shapes
The shape language is organic and approachable, utilizing a graduated corner radius system to differentiate between component types.

- **Small (8-12px):** Used for functional UI like input fields and tags/chips.
- **Medium (16px):** The standard for content cards and information blocks.
- **Large (20px):** Reserved for modal sheets and full-screen dialogs.
- **Extra Large (28px+):** Used for the "AI Orb" and Floating Action Buttons (FABs) to emphasize their role as primary interaction points.

## Components
- **The AI Orb:** A circular component (Radius XL) that pulses with a gradient glow (Blue to Teal) when listening. It uses a high-blur backdrop to appear "levitating."
- **Buttons:** Primary buttons use a solid gradient fill. Secondary buttons use a "Ghost" style with a 1.5px glowing border. Minimum height: 56px for primary actions.
- **Cards:** Glassmorphic containers with 16px corner radius. They should include a subtle 0.5px white border on the top and left to simulate a light source.
- **Chips:** Small, pill-shaped tags (Radius XS) used for quick-reply suggestions during voice conversation.
- **Input Fields:** Soft-filled containers (Radius S) with warm-neutral backgrounds. Upon focus, the border transitions to a Primary Blue glow.
- **Lists:** Clean, borderless list items separated by 8px of vertical space, utilizing large icons (24px) for clear visual categorization.