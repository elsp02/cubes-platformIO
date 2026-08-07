// ============================================================
// Bachelor Thesis – General Typst Template
// ============================================================


// ------------------------------------------------------------
// DOCUMENT INFORMATION
// ------------------------------------------------------------

#let thesis-title = [Title of the Bachelor Thesis]
#let thesis-subtitle = none

#let author = [Elena Spitzer]

#let university = [University of Applied Sciences Augsburg]
#let faculty = [Faculty of Electrical Engineering]
#let degree-program = [Creative Engineering]

#let thesis-type = [Bachelor Thesis]

#let supervisor = [Claudia Meitinger]
#let second-supervisor = [Second Supervisor]

#let submission-date = [August 2026]


// ------------------------------------------------------------
// GENERAL DOCUMENT SETTINGS
// ------------------------------------------------------------

#set document(
  title: thesis-title,
)

#set page(
  paper: "a4",
  margin: (
    top: 2.5cm,
    bottom: 2.5cm,
    left: 3cm,
    right: 2.5cm,
  ),
)

#set text(
  size: 11pt,
  lang: "en",
)

#set par(
  justify: true,
  leading: 0.65em,
)


// ------------------------------------------------------------
// HEADINGS
// ------------------------------------------------------------

#set heading(numbering: "1.1")

#show heading.where(level: 1): it => {
  set text(size: 18pt, weight: "bold")
  block(
    above: 1.5em,
    below: 1em,
    it,
  )
}

#show heading.where(level: 2): it => {
  set text(size: 14pt, weight: "bold")
  block(
    above: 1.2em,
    below: 0.7em,
    it,
  )
}

#show heading.where(level: 3): it => {
  set text(size: 11pt, weight: "bold")
  block(
    above: 1em,
    below: 0.5em,
    it,
  )
}


// ------------------------------------------------------------
// FIGURES AND TABLES
// ------------------------------------------------------------

#show figure.caption: set text(size: 9pt)


// ============================================================
// TITLE PAGE
// ============================================================

#set page(numbering: none)

#align(center)[

  #v(2cm)

  #text(size: 14pt, weight: "bold")[
    #university
  ]

  #v(0.4cm)

  #text(size: 11pt)[
    #faculty \
    #degree-program
  ]

  #v(3.5cm)

  #text(size: 14pt, weight: "bold")[
    #thesis-type
  ]

  #v(1cm)

  #text(size: 24pt, weight: "bold")[
    #thesis-title
  ]

  #if thesis-subtitle != none [
    #v(0.5cm)
    #text(size: 14pt)[
      #thesis-subtitle
    ]
  ]

  #v(2.5cm)

  #text(size: 12pt)[
    submitted by \
    *#author*
  ]

  #v(1.5cm)

  #table(
    columns: (auto, 1fr),
    stroke: none,
    column-gutter: 1cm,

    [Supervisor:], [#supervisor],
    [Second Supervisor:], [#second-supervisor],
    [Submission Date:], [#submission-date],
  )
]

#pagebreak()


// ============================================================
// FRONT MATTER
// ============================================================

#set page(numbering: "i")
#counter(page).update(1)


// ------------------------------------------------------------
// ABSTRACT
// ------------------------------------------------------------

#heading(
  numbering: none,
  outlined: false,
)[Abstract]

This thesis ...


#pagebreak()


// ------------------------------------------------------------
// TABLE OF CONTENTS
// ------------------------------------------------------------

#outline(
  title: [Table of Contents],
  depth: 2,
)

#pagebreak()


// ------------------------------------------------------------
// OPTIONAL: LIST OF FIGURES
// ------------------------------------------------------------

// #outline(
//   title: [List of Figures],
//   target: figure.where(kind: image),
// )

// #pagebreak()


// ------------------------------------------------------------
// OPTIONAL: LIST OF TABLES
// ------------------------------------------------------------

// #outline(
//   title: [List of Tables],
//   target: figure.where(kind: table),
// )

// #pagebreak()


// ============================================================
// MAIN MATTER
// ============================================================

#set page(numbering: "1")
#counter(page).update(1)


// ------------------------------------------------------------
// CHAPTERS
// ------------------------------------------------------------

#include "sonderpädagogischer_kontext_engl.typ"

#include "lerntheorethische_grundlagen_engl.typ"

#include "tui_engl.typ"

#include "verwandte_systeme.typ"

#include "anforderungsanalyse_engl.typ"


// Weitere Kapitel später beispielsweise:
//
// #include "konzept.typ"
// #include "implementierung.typ"
// #include "evaluation.typ"
// #include "discussion.typ"
// #include "conclusion.typ"


// ============================================================
// REFERENCES
// ============================================================

#pagebreak()

#bibliography(
  "bib.bib",
  title: [References],
  style: "ieee",
)
