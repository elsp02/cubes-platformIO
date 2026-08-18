// ============================================================
// Bachelor Thesis – General Typst Template
// ============================================================
#import "@preview/abbr:0.3.1"

#show: abbr.show-rule

// ------------------------------------------------------------
// DOCUMENT INFORMATION
// ------------------------------------------------------------

#let thesis-title = [Design and Development of a Tangible Learning System for
Special Education]
#let thesis-subtitle = none

#let author = [Elena Spitzer]

#let university = [University of Applied Sciences Augsburg]
#let faculty = [Faculty of Electrical Engineering]
#let degree-program = [Creative Engineering]

#let thesis-type = [Bachelor Thesis]

#let supervisor = [Prof. Dr. Claudia Meitinger]
#let second-supervisor = [Prof. Dr.-Ing. Christoph Zeuke]

#let submission-date = [18. August 2026]


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
  spacing: 0.65em,
  first-line-indent: 1.5em,
)

#set list(
  indent: 1.7em,
  body-indent: 0.5em,
)

// Figures nicht im Blocksatz
#show figure: set par(justify: false)


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
  set text(size: 15pt, weight: "bold")
  block(
    above: 1.2em,
    below: 0.7em,
    it,
  )
}

#show heading.where(level: 3): it => {
  set text(size: 13pt, weight: "bold")
  block(
    above: 1.2em,
    below: 0.8em,
    it, // oder it.body wenn level 3 keine Nummerierung mehr haben soll
  )
}

#show heading.where(level: 4): it => {
  set text(size: 11pt, weight: "bold")
  block(
    above: 1.1em,
    below: 0.8em,
    it.body, // oder it.body wenn level 3 keine Nummerierung mehr haben soll
  )
}


// ------------------------------------------------------------
// FIGURES AND TABLES
// ------------------------------------------------------------

#show figure.caption: set text(size: 10pt)



// ============================================================
// TITLE PAGE
// ============================================================

#set page(numbering: none)

#place(top + right, image("figures/THA-Logo.png", width: 30%))

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

  #align(center)[
    #table(
      columns: (auto, auto),
      stroke: none,
      column-gutter: 4cm,
      //align: (right + horizon, left + horizon),  // aligned text jeweils in die mitte

      [Supervisor:], [#supervisor],
      [Second Supervisor:], [#second-supervisor],
      [Submission Date:], [#submission-date],
    )
  ]
]

#pagebreak()


// ============================================================
// FRONT MATTER
// ============================================================

#set page(
  numbering: "i",

  footer: context [
    #line(
      length: 100%,
      stroke: 0.5pt,
    )

    #v(3pt)

    #align(center)[
      #counter(page).display("i")
    ]
  ],
)

#counter(page).update(1)
// Declaration


#include "declaration.typ"

// ------------------------------------------------------------
// ABSTRACT
// ------------------------------------------------------------
#pagebreak()
#heading(
  numbering: none,
  outlined: false,
)[Abstract]

This thesis ...


#pagebreak()


// ------------------------------------------------------------
// TABLE OF CONTENTS
// ------------------------------------------------------------

#{
  show outline.entry.where(level: 1): it => strong(it)

  outline(
    title: [Table of Contents],
    depth: 2,
  )
}

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

#set page(
  numbering: "1",

  // ----------------------------------------------------------
  // HEADER
  // ----------------------------------------------------------

  header: context {
    let current-page = here().page()

    // All level-1 headings in the document
    let chapters = query(
      heading.where(level: 1)
    )

    // Check whether a new chapter starts on this page
    let chapter-start-page = chapters.any(
      chapter => chapter.location().page() == current-page
    )

    // No header on the first page of a chapter
    if not chapter-start-page {

      // Find the most recent level-1 heading
      let previous-chapters = query(
        selector(heading.where(level: 1)).before(here())
      )

      if previous-chapters.len() > 0 {
        let chapter = previous-chapters.last()

        [
          #set text(size: 10pt)

          #align(center)[
          #emph[#chapter.body]
          ]

          #v(3pt)

          #line(
            length: 100%,
            stroke: 0.5pt,
          )
        ]
      }
    }
  },

  // ----------------------------------------------------------
  // FOOTER
  // ----------------------------------------------------------

  footer: context [
    #line(
      length: 100%,
      stroke: 0.5pt,
    )

    #v(3pt)

    #align(center)[
      #counter(page).display()
    ]
  ],
)

#counter(page).update(1)
// ============================================================
// Abbreviations
// ============================================================
#abbr.make(
  ("ASD", "Autism Spectrum Disorder"),
  ("GUI", "Graphical User Interface"),
  ("GE", "Special education focus on intellectual development"),
  ("ID", "Identification"),
  ("LE", "Special education focus on learning"),
  ("LED", "Light-Emitting Diode"),
  ("MVC", "Model View Controller"),
  ("MCRpd", "Model-Control-Representatio (physical and digital"),
  ("NFC", "Near Field Communication"),
  ("rep_p", "Physical Representation"),
  ("rep_d", "Digital Representation"),
  ("RFID", "Radio Frequency Identification"),
  ("RGB", "red-green-blue"),
  ("TUI", "Tangible User Interface"),
  ("UHF", "Ultra High Frequency"),
  ("UI", "User Interface"),
  ("3D", "Three Dimensional")

)
// ------------------------------------------------------------
// CHAPTERS
// ------------------------------------------------------------

#include "sonderpädagogischer_kontext_engl.typ"

#pagebreak()

#include "lerntheorethische_grundlagen_engl.typ"

#include "tui_engl.typ"

#pagebreak()
#include "verwandte_systeme.typ"
#pagebreak()

#include "anforderungsanalyse_engl.typ"

#pagebreak()

#include "systemkonzept_engl.typ"

// Weitere Kapitel später beispielsweise:
//
//#include "systemkonzept2.typ"
#pagebreak()
#include "implementierung_engl.typ"
#pagebreak()
 #include "evaluation_engl.typ"
// #include "discussion.typ"
// #include "conclusion.typ"


// ============================================================
// REFERENCES
// ============================================================

#pagebreak()

#abbr.list(
  title: "List of Abbreviations",
)

// ------------------------------------------------------------
// OPTIONAL: LIST OF FIGURES
// ------------------------------------------------------------
#{
  show outline.entry: it => link(
    it.element.location(),
    it.indented(
      strong(it.prefix()),
      [
        #it.body()
        #box(width: 1fr, it.fill)
        #it.page()
      ],
    ),
  )

  outline(
    title: [List of Figures],
    target: figure.where(kind: image),
  )
}

// ------------------------------------------------------------
// OPTIONAL: LIST OF TABLES
// ------------------------------------------------------------
#{
  show outline.entry: it => link(
    it.element.location(),
    it.indented(
      strong(it.prefix()),
      [
        #it.body()
        #box(width: 1fr, it.fill)
        #it.page()
      ],
    ),
  )

  outline(
    title: [List of Tables],
    target: figure.where(kind: table),
  )
}
 #pagebreak()


#bibliography(
  ("bib.bib", "bib_manual.bib"),
  title: [References],
  style: "ieee-grouped.csl",
)

