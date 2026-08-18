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

#let submission-date = [18 August 2026]


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

// Do not justify figure captions
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
    it, // Use it.body instead if level-3 headings should not be numbered
  )
}

#show heading.where(level: 4): it => {
  set text(size: 11pt, weight: "bold")
  block(
    above: 1.1em,
    below: 0.8em,
    it.body, // Use it instead if level-4 headings should be numbered
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
      //align: (right + horizon, left + horizon), // Align text vertically in the centre

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

Children with special educational needs benefit from concrete, action-oriented learning opportunities that accommodate different cognitive, perceptual and motor abilities. This thesis presents a modular, brick-based tangible learning game that combines the haptic and spatial qualities of physical construction materials with digital task presentation, construction detection and feedback. Learners select a three-dimensional target structure in a browser-based application and reproduce it using electronically connected building bricks. The system was designed to create opportunities for spatial thinking, action planning, problem-solving and increasingly independent learning while allowing task complexity and assistance to be adapted to individual needs. A prototype comprising two brick geometries, a central baseplate, embedded communication and a learning application was developed and assessed against requirements derived from learning theory, tangible interaction and the special education context. A formative qualitative evaluation was conducted with ten students from one class at a special education school. Because electronic construction detection was not sufficiently reliable during the session, the students evaluated the physical bricks, target selection and three-dimensional visualisation, while the remaining functions were assessed analytically. The students understood the reconstruction task, interacted willingly with the physical and digital elements and completed structures of varying complexity. The tangible materials also encouraged experimentation and spontaneous peer support. However, the integrated detection and feedback cycle, graduated assistance and multimodal output remain to be implemented reliably and evaluated with the target group. The results therefore do not demonstrate learning gains, but they provide formative evidence that the central interaction concept is accessible, engaging and suitable as a foundation for a tangible learning system in special education.


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
  ("MCRpd", "Model–Control–Representation (physical and digital)"),
  ("NFC", "Near Field Communication"),
  ("rep_p", "Physical Representation"),
  ("rep_d", "Digital Representation"),
  ("RFID", "Radio Frequency Identification"),
  ("RGB", "red-green-blue"),
  ("TUI", "Tangible User Interface"),
  ("UHF", "Ultra High Frequency"),
  ("UI", "User Interface"),
  ("3D", "Three-Dimensional")

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

// Additional chapters can be included here later, for example:
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

#pagebreak()
#counter(heading).update(0)
#set heading(numbering: "A.1")
#include "appendix.typ"

