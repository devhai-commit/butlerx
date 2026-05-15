---
name: ButlerX High-Contrast System
colors:
  surface: '#f9f9f9'
  surface-dim: '#dadada'
  surface-bright: '#f9f9f9'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f3f3'
  surface-container: '#eeeeee'
  surface-container-high: '#e8e8e8'
  surface-container-highest: '#e2e2e2'
  on-surface: '#1a1c1c'
  on-surface-variant: '#434652'
  inverse-surface: '#2f3131'
  inverse-on-surface: '#f1f1f1'
  outline: '#737783'
  outline-variant: '#c3c6d4'
  surface-tint: '#2b5bb5'
  primary: '#003178'
  on-primary: '#ffffff'
  primary-container: '#0d47a1'
  on-primary-container: '#a1bbff'
  inverse-primary: '#b0c6ff'
  secondary: '#5e5e5e'
  on-secondary: '#ffffff'
  secondary-container: '#e2e2e2'
  on-secondary-container: '#646464'
  tertiary: '#602100'
  on-tertiary: '#ffffff'
  tertiary-container: '#853100'
  on-tertiary-container: '#ffa781'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d9e2ff'
  primary-fixed-dim: '#b0c6ff'
  on-primary-fixed: '#001945'
  on-primary-fixed-variant: '#00429c'
  secondary-fixed: '#e2e2e2'
  secondary-fixed-dim: '#c6c6c6'
  on-secondary-fixed: '#1b1b1b'
  on-secondary-fixed-variant: '#474747'
  tertiary-fixed: '#ffdbcd'
  tertiary-fixed-dim: '#ffb596'
  on-tertiary-fixed: '#360f00'
  on-tertiary-fixed-variant: '#7d2d00'
  background: '#f9f9f9'
  on-background: '#1a1c1c'
  surface-variant: '#e2e2e2'
typography:
  headline-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 36px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Be Vietnam Pro
    fontSize: 28px
    fontWeight: '700'
    lineHeight: '1.3'
  headline-sm:
    fontFamily: Be Vietnam Pro
    fontSize: 24px
    fontWeight: '700'
    lineHeight: '1.3'
  body-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 20px
    fontWeight: '600'
    lineHeight: '1.5'
  body-md:
    fontFamily: Be Vietnam Pro
    fontSize: 19px
    fontWeight: '600'
    lineHeight: '1.5'
  label-md:
    fontFamily: Be Vietnam Pro
    fontSize: 17px
    fontWeight: '600'
    lineHeight: '1.4'
  label-sm:
    fontFamily: Be Vietnam Pro
    fontSize: 16px
    fontWeight: '600'
    lineHeight: '1.4'
  headline-lg-mobile:
    fontFamily: Be Vietnam Pro
    fontSize: 32px
    fontWeight: '700'
    lineHeight: '1.2'
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  touch-target-min: 56px
  gutter: 24px
  margin-mobile: 20px
  margin-desktop: 48px
  stack-sm: 12px
  stack-md: 24px
  stack-lg: 40px
---

## Brand & Style
The design system is engineered for maximum legibility, clarity, and ease of use, specifically tailored for an older demographic (60+). The brand personality is reliable, supportive, and dignified—functioning as a high-end digital concierge that prioritizes function over decorative trends. 

The aesthetic is a refined **High-Contrast** style. It rejects subtle gradients, thin weights, and low-contrast overlays in favor of solid forms, heavy borders, and absolute color values. This ensures that users with varying degrees of visual impairment or cognitive load can navigate the interface with total confidence. The UI feels architectural and stable, evoking an emotional response of safety and competence.

## Colors
This design system utilizes a high-contrast palette to guarantee WCAG AAA compliance across all critical paths. 

- **Primary:** Deep Blue (#0D47A1) serves as the anchor for all primary actions and interactive states, providing a strong visual signal that remains distinct from black text.
- **Background & Surface:** The canvas is Pure White (#FFFFFF). Secondary surfaces use a Light Gray (#F5F5F5) to create subtle containment without muddying the visual hierarchy.
- **Text:** Pure Black (#000000) is used for all content to achieve the maximum possible contrast ratio against white and light gray backgrounds.
- **Functional Borders:** Instead of shadows, the system relies on solid 1px and 2px borders to define the boundaries of interactive elements and containers.

## Typography
The typography system uses **Be Vietnam Pro**, chosen for its generous x-height and open counters which aid readability. Following a +4sp increase across all tiers, the scale is optimized for users who may have decreased visual acuity.

Key constraints:
- **Weights:** Only SemiBold (600) and Bold (700) are utilized to ensure characters never appear "faint" or "wispy."
- **Line Height:** Tight leading is avoided; a minimum of 1.5x is preferred for body text to prevent lines from blurring together during reading.
- **Readability:** All labels and captions are kept above 16px to ensure accessibility without the need for manual zooming.

## Layout & Spacing
The layout follows a **Fixed Grid** philosophy to maintain predictability. Predictability is a core accessibility feature; elements should appear where users expect them to be.

- **Touch Fidelity:** A strict minimum touch target of 56x56px is enforced for all interactive elements (buttons, icons, checkboxes) to accommodate users with reduced motor precision or tremors.
- **Breathing Room:** We use a generous 8px base unit. Gutters are set to 24px to ensure that distinct functional areas do not visually bleed into one another.
- **Vertical Rhythm:** A "Stack" model is used for vertical spacing, with 40px gaps between major sections to provide a clear cognitive break between different types of information.

## Elevation & Depth
This design system abandons traditional shadows and glassmorphism in favor of **Structural Outlines**. 

- **Containment:** Depth is conveyed through 1px solid borders (#000000 at 10-20% opacity or solid gray) around cards and containers.
- **Interactive Depth:** Focused or active elements use a 2px solid Deep Blue (#0D47A1) border. This creates a "stamped" or "cut-out" effect that is much easier to perceive than soft ambient shadows.
- **Layering:** When modals or overlays are required, a high-opacity (60%) dark scrim is used to completely isolate the background, preventing visual noise from interfering with the primary task.

## Shapes
The shape language uses **Rounded (Level 2)** settings to strike a balance between a friendly, approachable feel and a structured, professional look. 

- **Standard Radius:** 0.5rem (8px) for buttons and input fields.
- **Container Radius:** 1rem (16px) for cards and large surface areas.
- **Why:** Rounded corners help the eye follow the "enclosed" nature of a button more easily than sharp corners, which can sometimes blend into the grid lines of the overall layout.

## Components

### Buttons
- **Primary:** Solid Deep Blue background with White text. Minimum height 56px.
- **Secondary:** White background with a 2px solid Black border and Black text.
- **States:** Active states must show a clear visual shift, such as an inverted color scheme or a weight increase in the border.

### Input Fields
- Fields must have a 2px solid border at all times.
- Backgrounds remain Pure White to ensure text contrast.
- Labels are always persistent (never disappearing placeholder text) and set in 17px SemiBold.

### Chips & Tags
- Used sparingly. They must be large enough to be clickable (min 48px height if interactive).
- Use high-contrast fills (e.g., Black fill with White text for "Selected" states).

### Lists & Navigation
- List items must be separated by a solid 1px horizontal rule.
- Every list item should include a bold chevron icon (> 24px) to clearly indicate it is a navigable element.

### Accessibility Requirements
- **Iconography:** Use bold/filled icons with a minimum stroke weight of 2px. Icons must always be accompanied by a text label.
- **Motion:** No critical information or navigation can be hidden behind motion-only triggers. Any animation must be simple (fade-in) and respect "Reduced Motion" system settings.