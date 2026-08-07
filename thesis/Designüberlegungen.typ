#set page(flipped: true)

#show table.cell.where(y: 0): set text(weight: "bold")

#let yellow-cells = (
  (3, 1),
  (4,2),
  (2,3),
  (4,4),
  (3,5),
  (4,5),
  (3,6),
  (2,7),
  (3,7),
  (4,7),
  (5,7),
  (4,8),
  
  (2,9),
  (3,9),
  (4,9),

  (2,10),
  (4,10),
  (3,11),
  (3,12),
  (2,13),
  (3,15),
)

#figure(
  table(
    columns: 6,
    stroke: luma(80%),


    fill: (x, y) => {
    if (x,y) in yellow-cells {
      yellow // Zelle Spalte 0, Zeile 1 gelb
    } else if y == 0 {
      gray.lighten(50%) // Ganze Kopfzeile
    } else {
      none
    }
    },

    table.header[
      Area
    ][
      Design Parameter
    ][
      Option A
    ][
      Option B
    ][
      Option C
    ][
      Option D
    ],

    [Educational concept],
    [Educational application],
    [Logical learning game],
    [Construction game],
    [Word or sentence game],
    [Programming game],

    [Physical design],
    [Shape of the building blocks],
    [Cube],
    [brick-like shape],
    [brick with square-base],
    [Free geometric shape],

    [Physical design],
    [Size and usage context],
    [Hand-sized, used on a table],
    [Large-scale, used on the floor],
    [Different block sizes],
    [-],

    [Physical design],
    [Spatial arrangement],
    [One-dimensional],
    [Two-dimensional],
    [Three-dimensional],
    [-],

    [Physical design],
    [Connection between building blocks],
    [No mechanical connection],
    [Magnetic connection],
    [Form-fitting connection],
    [Mechanical locking connection],

    [System recognition],
    [Identification of building blocks],
    [Identification of block type],
    [Identification of block type and instance],
    [-],
    [-],

    [System recognition],
    [Detection of the construction],
    [Presence of building blocks],
    [Neighbouring relationships],
    [Connected sides],
    [Position and orientation],

    [Interaction],
    [Visualisation of the construction],
    [No additional visualisation],
    [Two-dimensional representation],
    [Three-dimensional representation],
    [Step-by-step instructions like],

    [Interaction],
    [Feedback dimension],
    [locally],
    [globally],
    [permanent],
    [deferred],

    [Interaction],
    [Feedback modality],
    [Visual feedback],
    [Auditory feedback],
    [Mechanical or haptic feedback],
    [Multimodal feedback],

    [Interaction],
    [Location of feedback],
    [Directly on each building block],
    [On a central base unit],
    [On an external display],
    [-],

    [Technical implementation],
    [Energy supply],
    [Individual energy source per block],
    [Central supply via the base unit],
    [Wireless energy transmission],
    [-],

    [Technical implementation],
    [Electrical connection],
    [Spring-loaded contacts],
    [Plug connectors],
    [Contactless transmission],
    [-],

    [Technical implementation],
    [System architecture],
    [Centralised recognition],
    [Decentralised recognition],
    [Recognition through a grid or mat],
    [Hybrid architecture],

    [System scope],
    [Number of building blocks],
    [Small fixed number (10 blocks)],
    [Scalable modular system],
    [-],
    [-],
  ),

  caption: [
    Morphological chart of the design parameters and potential configurations
    of the tangible learning system
  ],
) <morphological-chart>
