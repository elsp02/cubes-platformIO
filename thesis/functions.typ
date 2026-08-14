//Table nach APA style
#let apa-table(
  columns: 3,
  header: (),
  caption: none,
  table-label: none,
  ..cells
) = {

  // Header row bold
  show table.cell.where(y: 0): set text(
    weight: "bold",
  )

  // Caption below the table
  show figure.where(kind: table): set figure.caption(
    position: bottom,
  )

  // Caption format:
  // Table 1: Title of the Table
  show figure.caption.where(kind: table): it => [
    #it.supplement #context it.counter.display(it.numbering): #emph[#it.body]
  ]

  let fig =figure(
    table(
      columns: columns,

      // No vertical/grid lines
      stroke: none,

      inset: (
        x: 6pt,
        y: 5pt,
      ),

      // Top line
      table.hline(
        stroke: 0.7pt,
      ),

      // Header
      table.header(
        ..header
      ),

      // Line below header
      table.hline(
        stroke: 0.3pt,
      ),

      // Table content
      ..cells,

      // Bottom line
      table.hline(
        stroke: 0.7pt,
      ),
    ),

    caption: caption,
  )

  // Attach label directly to the figure
  if table-label == none {
    fig
  } else {
    [#fig #table-label]
  }
}
}

// ID verknüpfen
// Requirement ID inside a table.
// Creates the destination for the hyperlink.
#let req-target(id) = [
  #box[#id] #label("req-" + id)
]

// Clickable requirement ID used in the text.
#let req(id) = link(
  label("req-" + id)
)[
  #text("[" + id + "]")
]