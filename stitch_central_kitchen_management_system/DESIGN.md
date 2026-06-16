---
name: Central Kitchen Pro
colors:
  surface: '#f8f9fb'
  surface-dim: '#d9dadc'
  surface-bright: '#f8f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f4f6'
  surface-container: '#edeef0'
  surface-container-high: '#e7e8ea'
  surface-container-highest: '#e1e2e4'
  on-surface: '#191c1e'
  on-surface-variant: '#444651'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#f0f1f3'
  outline: '#757682'
  outline-variant: '#c5c5d3'
  surface-tint: '#4059aa'
  primary: '#00236f'
  on-primary: '#ffffff'
  primary-container: '#1e3a8a'
  on-primary-container: '#90a8ff'
  inverse-primary: '#b6c4ff'
  secondary: '#0058be'
  on-secondary: '#ffffff'
  secondary-container: '#2170e4'
  on-secondary-container: '#fefcff'
  tertiary: '#00311f'
  on-tertiary: '#ffffff'
  tertiary-container: '#004a31'
  on-tertiary-container: '#27c38a'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dce1ff'
  primary-fixed-dim: '#b6c4ff'
  on-primary-fixed: '#00164e'
  on-primary-fixed-variant: '#264191'
  secondary-fixed: '#d8e2ff'
  secondary-fixed-dim: '#adc6ff'
  on-secondary-fixed: '#001a42'
  on-secondary-fixed-variant: '#004395'
  tertiary-fixed: '#6ffbbe'
  tertiary-fixed-dim: '#4edea3'
  on-tertiary-fixed: '#002113'
  on-tertiary-fixed-variant: '#005236'
  background: '#f8f9fb'
  on-background: '#191c1e'
  surface-variant: '#e1e2e4'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-sm:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  title-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  container-margin: 24px
  gutter: 16px
---

## Brand & Style
The design system is engineered for high-efficiency logistics and franchise operations. It prioritizes clarity, speed of data entry, and reliability. The brand personality is authoritative yet supportive, functioning as a silent partner in complex kitchen environments.

The design style is **Corporate Modern with a Minimalist focus**. It leverages a high-contrast interface to ensure readability in fast-paced kitchen environments where lighting may vary. The aesthetic is professional and functional, avoiding unnecessary decoration to keep the user focused on inventory levels, order statuses, and logistics workflows. It adopts a systematic approach to information density, ensuring that large data sets remain digestible.

## Colors
This design system utilizes a high-contrast corporate palette. 
- **Primary:** The dark blue (#1E3A8A) is used for global navigation, primary actions, and brand identification, conveying stability and trust.
- **Secondary:** A lighter blue (#3B82F6) is used for interactive elements like links and active states.
- **Status Colors:** Functional greens (#10B981) for "In Stock" or "Completed," and reds (#EF4444) for "Critical Low" or "Cancelled."
- **Backgrounds:** A tiered neutral system using #F3F4F6 for the main canvas and pure white (#FFFFFF) for cards and data containers to create a clear "layering" effect that aids focus.

## Typography
The typography system uses **Inter** for its exceptional legibility and neutral, systematic tone. It follows a modular scale that favors readability for data-heavy views.

- **Headlines:** Use SemiBold (600) to create a clear visual hierarchy against white surfaces.
- **Body:** The standard size is 14px for data tables and form labels to maximize the information visible on a single screen without sacrificing legibility.
- **Labels:** Small, uppercase labels with increased letter spacing are used for metadata and category headers to distinguish them from actionable content.
- **Mobile:** Typography scales down slightly on mobile to prevent overflow in narrow columns, prioritizing vertical rhythm.

## Layout & Spacing
The layout follows a **Fixed-Fluid hybrid grid**. 
- **Desktop:** 12-column grid with a max-width of 1440px for content containers, 24px margins, and 16px gutters.
- **Sidebar:** A fixed 260px navigation sidebar on the left for quick access to Inventory, Orders, and Stores.
- **Spacing Rhythm:** Based on a 4px baseline grid. Use 16px (md) for standard padding within cards and 8px (sm) for related element groupings.
- **Adaptability:** On mobile, the grid shifts to a single column with 16px margins. Cards become full-width to maximize touch targets for kitchen staff.

## Elevation & Depth
Depth is conveyed through **Tonal Layers and Subtle Shadows**. 
- **Level 0 (Canvas):** The #F3F4F6 background acts as the lowest layer.
- **Level 1 (Cards/Content):** Pure white surfaces with a soft, 4px blur shadow (Color: #000000 at 5% opacity). This creates a "lift" that separates content from the background without feeling heavy.
- **Level 2 (Modals/Dropdowns):** Higher elevation with an 8px blur shadow (Color: #000000 at 10% opacity) to indicate temporary, focused interaction.
- **Outlines:** Low-contrast 1px borders (#E5E7EB) are used on all Level 1 surfaces to maintain crisp definitions in high-glare environments.

## Shapes
The design system uses a **Rounded** shape language to soften the industrial nature of logistics software while remaining professional. 
- **Standard UI Elements:** Buttons and Input fields use an 8px (0.5rem) radius.
- **Containers:** Large cards and dashboard widgets use a 16px (1rem) radius.
- **Chips:** Status indicators and tags use a full pill-shape (999px) to clearly differentiate them from interactive buttons.

## Components
- **Buttons:** Primary buttons use the corporate dark blue with white text. Secondary buttons use a ghost style with a 1px #D1D5DB border. Minimum touch target is 44px height.
- **Inputs:** Fields must have a clear 1px border. The active state uses a 2px #3B82F6 border with a subtle outer glow. Essential for "Central Kitchen Pro" are numeric steppers for inventory adjustment.
- **Chips/Status:** Color-coded for logistics status (e.g., "Pending" = Grey, "In Transit" = Blue, "Delivered" = Green).
- **Data Tables:** High-density rows with alternating subtle zebra-striping. Headers are sticky to ensure context is never lost during scrolling.
- **Cards:** Used for franchise summaries. Each card should have a consistent header area for the Store Name and a footer for primary "View Details" actions.
- **Inventory Bar:** A custom component showing stock levels as a horizontal gauge (Green/Yellow/Red) within list items.