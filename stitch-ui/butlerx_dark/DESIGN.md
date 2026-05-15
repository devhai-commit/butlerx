---
name: ButlerX Dark
colors:
  surface: '#111318'
  surface-dim: '#111318'
  surface-bright: '#37393e'
  surface-container-lowest: '#0c0e13'
  surface-container-low: '#191c20'
  surface-container: '#1d2024'
  surface-container-high: '#282a2f'
  surface-container-highest: '#33353a'
  on-surface: '#e2e2e9'
  on-surface-variant: '#c2c6d2'
  inverse-surface: '#e2e2e9'
  inverse-on-surface: '#2e3035'
  outline: '#8c919c'
  outline-variant: '#424751'
  surface-tint: '#a9c7ff'
  primary: '#b1ccff'
  on-primary: '#003063'
  primary-container: '#82b1ff'
  on-primary-container: '#004285'
  inverse-primary: '#295ea6'
  secondary: '#41e4c0'
  on-secondary: '#00382d'
  secondary-container: '#00c7a5'
  on-secondary-container: '#004d3f'
  tertiary: '#d8c2ff'
  on-tertiary: '#38265b'
  tertiary-container: '#bca6e4'
  on-tertiary-container: '#4c3970'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d6e3ff'
  primary-fixed-dim: '#a9c7ff'
  on-primary-fixed: '#001b3d'
  on-primary-fixed-variant: '#00468c'
  secondary-fixed: '#5ffbd6'
  secondary-fixed-dim: '#38debb'
  on-secondary-fixed: '#002019'
  on-secondary-fixed-variant: '#005142'
  tertiary-fixed: '#ebdcff'
  tertiary-fixed-dim: '#d3bcfc'
  on-tertiary-fixed: '#230f45'
  on-tertiary-fixed-variant: '#503d73'
  background: '#111318'
  on-background: '#e2e2e9'
  surface-variant: '#33353a'
typography:
  display-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 56px
    fontWeight: '700'
    lineHeight: 64px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Be Vietnam Pro
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  body-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Be Vietnam Pro
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Be Vietnam Pro
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  gutter-mobile: 16px
  gutter-desktop: 24px
  margin-mobile: 20px
  margin-desktop: 48px
  touch-target-min: 48px
---

## Brand & Style
The design system evolves into a "Midnight Concierge" aesthetic, shifting from the airy daylight of the original into a focused, low-light environment. It maintains the "Soft Futurism" through the lens of a high-end night-time interface—evoking the feeling of a calm, intelligent presence in a quiet home.

The "Vietnamese warmth" is preserved not through brightness, but through soft, glowing accents that mimic the gentle amber of a street lantern or the bioluminescent pulse of a digital assistant. The style is a hybrid of **Glassmorphism** and **Minimalism**, using deep charcoal surfaces and soft-focus blurs to create a sense of infinite depth while maintaining accessibility and focus.

## Colors
The palette shifts to a deep navy-charcoal base (`#12141C`) to reduce eye strain and provide a canvas for the "Jarvis Orb" glow effects.
- **Primary (#82B1FF):** An electric, soft blue used for active states and critical intelligence prompts.
- **Secondary (#64FFDA):** A minty teal reserved for "Active/Success" modes and energy-efficient home controls.
- **Tertiary (#B39DDB):** A soft lavender for lifestyle features, scheduling, and secondary context.
- **Surface Strategy:** Layers are built using increasing lightness rather than shadows. Higher elevation items use a more translucent, frosted dark glass texture.

## Typography
This design system utilizes **Be Vietnam Pro** across all levels to maintain a friendly, contemporary, and highly legible tone. In Dark Mode, font weights are slightly compensated (avoiding ultra-thin weights) to prevent "halonation" on dark backgrounds. 

Large-scale headlines use a tighter letter-spacing for a more premium, editorial feel, while body text maintains generous line-heights to ensure the "Vietnamese warmth" translates into a comfortable reading experience.

## Layout & Spacing
The layout follows a **Fluid Grid** philosophy with a strong emphasis on whitespace to prevent the dark interface from feeling cramped. 
- **Rhythm:** An 8px base grid drives all padding and margins.
- **Touch Targets:** A strict 48px minimum height/width for all interactive elements to ensure accessibility for all users.
- **Reflow:** On mobile, content stacks into a single column with 20px side margins. On desktop, a 12-column grid is used with a max-width of 1440px to ensure the interface remains centered and scannable.

## Elevation & Depth
Depth in this design system is created through **Dark Glassmorphism** and subtle **Glowing Borders**. 
- **Base Level:** The deep charcoal background.
- **Mid Level:** Surface containers with a 5% white overlay to create a "raised" effect.
- **Top Level (Interactive):** Dark frosted glass elements (Background-blur: 20px, Opacity: 85%) with a 1px inner border.
- **State Borders:** The 1px border inherits the primary or secondary color with a soft 4px outer glow (neon-style) to indicate which element is currently being "thought about" by the system.

## Shapes
Shapes are intentionally friendly and organic. 
- **Standard UI elements:** Use a 0.5rem (8px) radius. 
- **Large Cards/Containers:** Use a 1.5rem (24px) radius to create a soft, non-threatening enclosure.
- **Buttons:** Use a fully rounded pill-shape (circular ends) to contrast against the more structured grid and signify high interactability.

## Components
- **Buttons:** Primary buttons are solid `#82B1FF` with dark text. Secondary buttons use an "Outlined Glow" style—a transparent center with a primary-colored border and a faint matching drop-shadow to simulate a light source.
- **Jarvis Orb:** The central interaction point. It uses a radial gradient of all three brand colors with a `backdrop-filter: blur(40px)`. Its pulse speed indicates system latency.
- **Glass Cards:** High-opacity dark glass. When active, the border glows with the Primary color. Headers within cards should use the Tertiary lavender for clear visual hierarchy.
- **Input Fields:** Deep charcoal backgrounds with a 1px border that "lights up" when focused. The cursor should match the Primary blue.
- **Chips:** Small, pill-shaped indicators with a subtle 10% opacity background of the color they represent (e.g., a green chip for "Lights On" uses 10% Secondary teal).
- **Lists:** Separated by low-contrast lines (`rgba(255, 255, 255, 0.05)`) with generous vertical padding to support high-accessibility touch targets.