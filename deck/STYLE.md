# Deck style — edit this, then run /deck

Theme: [slidev-theme-dracula](https://github.com/jd-solanki/slidev-theme-dracula) (dark, Nunito Sans + JetBrains Mono).
The theme styles text, headings and code. `/deck` applies the rest of this file through
`styles/index.css` (small overrides only).

## Palette (Dracula)
| Token        | Hex     | Use |
|--------------|---------|-----|
| background   | #282A36 | slide background (theme) |
| current-line | #44475A | diagram node fill, panels |
| foreground   | #F8F8F2 | body text |
| comment      | #6272A4 | captions, diagram lines, external systems |
| purple       | #BD93F9 | titles (theme), data stores |
| cyan         | #8BE9FD | core components |
| green        | #50FA7B | AI / agent components |
| orange       | #FFB86C | emphasis, key numbers (theme's bold) |
| pink         | #FF79C6 | sparingly: the one thing to remember on a slide |
| red          | #FF5555 | risks |
| yellow       | #F1FA8C | inline code (theme) |

## Layouts to use (from the theme)
`cover` for slide 1 · `section` between parts · `statement` for the one-line design summary ·
`fact` for a headline number · `quote` only for a client/brief quote. Everything else: default layout.

## Diagrams
Every diagram is a diagram-design PNG from /diagrams (source in docs/design/diagrams/, copied to
public/diagrams/), shown with `<img src="/diagrams/<name>.png" class="diagram">` (`diagram-sm` under a
heading plus caption). No Mermaid. Colours, shapes and the one accent come from the PROJECT OVERRIDE in
the diagram-design skill. At most 12 nodes on a slide; check the slide PNG for clipping.

## Slide rules
- Title states the takeaway ("Permissions are enforced at query time"), not the topic ("Permissions").
- One idea per slide: at most 25 words of body, or one diagram plus a one-line caption.
- Every number also appears in docs/design; mark assumed numbers "(assumed)".
- Dark theme: no text in comment colour smaller than body size; check contrast in the PNG export.
