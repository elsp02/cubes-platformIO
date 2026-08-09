#set text(lang: "en")
#set page(numbering: "1")
#set par(justify: true)

= Fundamentals of learning theory 
The ways in which children acquire and apply new knowledge can be explained through different theoretical perspectives. These perspectives differ primarily in their understanding of how knowledge is formed, which role learners assume within the learning process and how learning environments should be designed. The three approaches discussed in the following, instructivism, constructivism, and constructionism, pursue different educational objectives but are all relevant to the development of learning systems. While instructivism primarily conceptualises learners as recipients of externally structured knowledge, constructivism and constructionism emphasise their active participation in the learning process. TABELLE BEZIEHEN

== Instructivism
Instructivism is based on the assumption that knowledge can be systematically structured and transmitted by a teacher. Learning primarily takes place through explanation and the reproduction of predefined content or procedures. The learner therefore assumes a comparatively receptive role, while the teacher determines the learning objectives, organises the subject matter, and provides the intended solution path. (quelle?)

== Constructivism
In contrast to the instructivist approach, constructivism defines learning as an active process in which learners independently engage with and shape the subject matter.
The fundamental principle of Piagets learning theory is illustrated by the quotation

"Thinking means constructing relationships. The individual comprehends the external world only by establishing relationships between its elements" (Piaget's constructivism, quoted in Vollmers, p. 79).

 Knowledge is therefore not conceived as a complete and objective representation of reality that exists independently of the learner. Instead, it is proposed that this phenomenon occurs as learners establish relationships between elements of their environment, interpret these relationships, and integrate them into their existing knowledge structures. The conceptual understanding of such abstract relationships is preceded by concrete experiences arising from physical interaction with objects in the environment. It is recommended that objects be touched, moved, compared with one another, or arranged spatially, with a view to generating experiences that provide the basis for the development of cognitive structures.

Learning is therefore described as an "interactive process between the learner and the external world" ([Author year, p. 75]). New knowledge does not emerge solely through the presentation of information, but primarily through active engagement with the object of learning.

== Constructionism

The mathematician and psychologist Seymour Papert extends the constructivist approach by adding an external dimension in his constructionist theory of learning. He argues that the construction of knowledge in the mind is most effective when it is supported by the construction of a tangible object in the physical world (Papert and Harel).Following the principle of “learning by making,” learners reconstruct knowledge while creating something of their own, thereby connecting the external construction of an artefact with the internal construction of knowledge.

The constructed artefact fulfils several functions: On the one hand, it makes abstract theoretical considerations concrete, tangible, and, in the literal sense, comprehensible. Relationships that may be difficult to understand when represented solely through language or graphics can become visible through the spatial arrangement of a physical model. On the other hand, modifying the model enables learners to test different assumptions and directly observe their effects. Austausch??

Papert even goes beyond the physical act of construction by emphasising the importance of personal meaning. Following the principle that “love is a better master than duty” (von einstein, Papert, p. 1), he argues that learning is enhanced when children create something that is personally meaningful to them.

== Comparison/Conclusion/Summary

Within the context of constructivism and constructionism, success is as important as failure and the occurrence of errors. Learning does not result merely from carrying out an activity. Instead, it develops through cognitive engagement with the constructed object and with the problems encountered during the construction process. Such difficulties create an opportunity for learners to review their planning and procedures and to reflect consciously on how the situation can be resolved and how their actions might be coordinated more effectively in future attempts (Vollmers, p. 79).

This conception of learning consequently also brings about a transformation in the role of the teacher ?compared to instuvtivism?. Rather than being responsible for transmitting knowledge in its entirety, the teacher is expected to create appropriate learning opportunities, prepare didactically structured tasks, and support learners when difficulties arise without anticipating or prescribing the complete solution.

However, the theoretical perspectives are not necessarily mutually exclusive in practical educational settings. Instructive elements may provide essential background knowledge or initial guidance, while constructivist and constructionist activities allow learners to actively apply, examine, and further develop this knowledge. The appropriate combination therefore depends on the learning objective, the learners’ prior knowledge, and the degree of guidance required.

#show table.cell.where(y: 0): set text(weight: "bold")

#figure(
  table(
    columns: 6,
    stroke: none,

    table.header[Approach][Guiding Principle][Construction of Knowledge][Learning Process][Role of learner][Role of Teacher],
    
    [Instructivism], [_Learning by listening_], [presented and transmitted through structured instruction], [Predetermined content and solution paths], [Passive recipient],[Transmits and explains knowledge],
    
    [Constructivism], [_Learning by doing_], [constructed through cognitive processes, reflection, and the recognition of relationships], [Exploration and problem-solving], [Active participant], [Guides and supports learning],

    [Constructionism], [_Learning by making_], [constructed through creation of a tangible, personally meaningful artefact], [Exploration, problem-solving and iterative construction], [Active creator], [Guides and supports learning],
    
  ),
  caption: [Comparison of learning approaches],
) <learning-approaches>

= Embodied Cognition and Interaction
While constructivism and constructionism explain why actively creating an externally perceivable artefact can support learning, they do not fully state the role played by bodily action and sensory perception during the construction process. This relationship is addressed by the theory of embodied cognition, which assumes that cognitive processes are inseparably connected to the body. Embodied interaction transfers this theoretical perspective to the design of interactive digital systems.

=== Embodied Cognition
Embodied cognition assumes that cognitive processes do not occur independently of the body but are shaped by perception, movement, and interaction with the environment. From this perspective, the physical manipulation of a learning object is not merely a means of executing an action that has already been fully planned mentally. Instead, the manipulation itself can form part of the processes of thinking and understanding and may therefore be considered as an integral component of the cognitive system (Liang, Embodied Interaction). Knowledge consequently emerges through the reciprocal relationship between the brain, the body, and the environment.

For learning processes, this implies that physical activities can be particularly relevant when they correspond meaningfully to the subject matter becuase arbitrary movement alone does not necessarily improve learning. (Liang, Embodied Interaction).Rather, the correspondence between the physical action and the concept to be learned is crucial. When learners are expected to understand a spatial relationship, for example, it may be beneficial for them to establish this relationship by physically positioning and rotating objects. In this case, the action does not merely represent the learning content symbolically but makes it directly accessible through bodily experience.

However, the educational value of physical interaction depends on the relationship between the performed action and the concept to be learned. Movement alone does not necessarily improve learning. The physical action must meaningfully correspond to the underlying content and make relevant properties or relationships directly perceivable.

== Embodied Interaction
While embodied cognition provides a theoretical perspective on the relationship between the body and cognition, embodied interaction transfers this principle to the design of interactive computer systems and is defined as a form of interaction that considers action to be a primary component of computer-supported representations (Embodied Interaction).

Dourish (2011) distinguishes between two dimensions of embodiment: physical presence in the world and social embeddedness within established practices and systems of meaning. Again, an object is not embodied merely because it exists in material form, what is decisive is how it is used and interpreted within a specific situation. Similarly, a user interface does not automatically enable embodied interaction simply because it involves physical actions. The actions performed through the interface must be comprehensible to users and must have a recognisable relationship to the system’s responses.

The aim of embodied interaction is therefore to design computer systems that do not restrict users to purely abstract forms of interaction but instead make effective use of their natural, everyday abilities and established ways of acting (Embodied Interaction)


== Comparison/Conclusion

Taken together, these theories indicate that the educational value of a tangible learning system does not result from physical activity or digital technology alone. It emerges from the coherent relationship between the learning objective, the actions performed by learners and the physical artefacts being manipulated. A suitable learning environment should therefore combine structured guidance with opportunities for independent exploration, construction, and meaningful bodily interaction.