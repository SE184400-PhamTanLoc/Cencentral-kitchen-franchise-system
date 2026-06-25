---
name: Core Operations System
colors:
  surface: '#faf8ff'
  surface-dim: '#dad9e0'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f4f3fa'
  surface-container: '#efedf4'
  surface-container-high: '#e9e7ee'
  surface-container-highest: '#e3e1e9'
  on-surface: '#1a1b20'
  on-surface-variant: '#444651'
  inverse-surface: '#2f3035'
  inverse-on-surface: '#f1f0f7'
  outline: '#757682'
  outline-variant: '#c5c5d3'
  surface-tint: '#425aa6'
  primary: '#001142'
  on-primary: '#ffffff'
  primary-container: '#00236f'
  on-primary-container: '#778ede'
  inverse-primary: '#b5c4ff'
  secondary: '#085ac0'
  on-secondary: '#ffffff'
  secondary-container: '#5b94fd'
  on-secondary-container: '#002c66'
  tertiary: '#320600'
  on-tertiary: '#ffffff'
  tertiary-container: '#551201'
  on-tertiary-container: '#da765a'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dce1ff'
  primary-fixed-dim: '#b5c4ff'
  on-primary-fixed: '#00164e'
  on-primary-fixed-variant: '#29428c'
  secondary-fixed: '#d8e2ff'
  secondary-fixed-dim: '#adc6ff'
  on-secondary-fixed: '#001a42'
  on-secondary-fixed-variant: '#004395'
  tertiary-fixed: '#ffdbd1'
  tertiary-fixed-dim: '#ffb5a1'
  on-tertiary-fixed: '#3b0900'
  on-tertiary-fixed-variant: '#7b2e18'
  background: '#faf8ff'
  on-background: '#1a1b20'
  surface-variant: '#e3e1e9'
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
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  title-lg:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
  title-md:
    fontFamily: Inter
    fontSize: 16px
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
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.1px
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.5px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  container-padding: 24px
  element-gap: 16px
  section-margin: 32px
  inline-padding: 12px
  grid-gutter: 16px
---

## Brand & Style

The design system is engineered for high-stakes operational environments, specifically central kitchens and franchise management. The brand personality is **authoritative, efficient, and transparent**. It prioritizes cognitive clarity over decorative flair, ensuring that complex logistics and inventory data remain the primary focus.

The visual style is **refined Minimalism with a Material 3 foundation**. It utilizes expansive white space to create "breathing room" in data-dense environments. By removing unnecessary heavy headers and opting for body-integrated typography, the UI feels lightweight and modern. The emotional response is one of calm control and professional reliability, moving away from cluttered legacy ERP aesthetics toward a high-fidelity, corporate tool.

## Colors

The palette is anchored by **Professional Deep Blue**, signaling stability and institutional trust. **Corporate Blue** acts as an energetic secondary for interactive highlights and secondary actions. 

The background uses a specific off-white (`#F8F9FB`) to reduce eye strain during long shifts, while the main surfaces (cards and containers) use pure white to create subtle "lift" without relying on heavy shadows. Semantic colors (Success, Warning, Error) follow standard industry conventions to ensure immediate recognition of system statuses and alerts.

## Typography

This design system utilizes **Inter** for its exceptional legibility and neutral, systematic tone. The typographic hierarchy is intentionally dramatic; page titles are prominent and bold to provide instant context, while body text remains functional and unobtrusive.

Large headlines use slight negative letter spacing to feel tighter and more "editorial." For data tables and forms, `label-lg` and `body-md` are the workhorses, ensuring high information density remains readable. Page titles should be integrated directly into the body layout rather than isolated in colored bars.

## Layout & Spacing

The layout follows a **fluid 12-column grid** on desktop, transitioning to a **4-column grid** on mobile. 

A standard **8px base unit** governs all spatial relationships. Navigation is handled via a persistent left-hand rail or drawer, allowing the content area to maximize horizontal space for tables and dashboards. 
- **Desktop:** 24px outer margins with 16px gutters.
- **Tablet:** 16px outer margins.
- **Mobile:** 12px outer margins; cards collapse to full width to maximize screen real estate.

## Elevation & Depth

In alignment with a clean, flat aesthetic, this design system minimizes the use of heavy shadows. 
- **Level 0 (Background):** `#F8F9FB`. No shadows.
- **Level 1 (Cards/Surfaces):** White background with a 1px border (`#E2E8F0`) or an extremely soft, 4% opacity neutral shadow.
- **Level 2 (Modals/Popovers):** Standard Material 3 "Elevated" style using a subtle 8% opacity shadow to indicate a distinct layer.

**AppBars** must remain at **Elevation 0**. They are distinguished from the content only by the background color transition or a very thin 1px bottom stroke, never by a shadow or dark fill.

## Shapes

The shape language differentiates between structural containers and interactive elements to provide visual cues for touch/click targets:
- **Structural (Cards, Large Modals):** 16px (`rounded-lg`) radius. This creates a soft, modern container for data groups.
- **Interactive (Buttons, Inputs, Chips):** 8px (`rounded-md`) radius. This sharper radius suggests precision and "tool-like" utility.
- **System Icons:** Should follow a consistent 2px stroke weight with rounded terminals to match the typography.

## Components

### Buttons
- **Primary:** Solid `#00236F` fill, white text, 8px radius.
- **Secondary:** Outlined with 1px stroke of `#0058BE`, 8px radius.
- **Ghost:** No fill or border, used for low-emphasis actions like "Cancel."

### Input Fields
- Outlined style only. 1px border in a soft neutral, turning to Primary `#00236F` (2px) on focus.
- Labels are positioned as "Floating Labels" per Material 3 spec.
- 8px border radius and 12px horizontal internal padding.

### Cards
- White background, 16px radius, 1px light neutral border.
- Internal padding should be a consistent 16px or 24px depending on the density of the content.

### Data Tables
- Header row uses a very subtle `#F1F5F9` background.
- Typography: `label-sm` for headers (all caps, 0.5px spacing) and `body-md` for row content.
- Clean dividers (1px) between rows; no vertical borders.

### Chips & Badges
- Used for "Order Status" or "Franchise Type."
- Soft tint backgrounds (10% opacity of the semantic color) with high-contrast text for maximum readability.