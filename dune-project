(lang dune 1.10)
(name nlopt)

(generate_opam_files false)

(source (github mkur/nlopt-ocaml))
(license "LGPL-2.1+ with OCaml linking exception")
(homepage "https://github.com/mkur/nlopt-ocaml")
(documentation "https://github.com/mkur/nlopt-ocaml")

(maintainers
  "Michał Kurcewicz        <michal.kurcewicz@gmail.com>"
)

(authors
  "Michał Kurcewicz       <michal.kurcewicz@gmail.com>"
  "Christophe Troestler   <Christophe.Troestler@umons.ac.be>"
)

(package
  (name nlopt)
  (synopsis "NLopt")
  (description "OCaml bindings to the NLOpt optimization library")
  (depends
    (ocaml (>= 4.08))
    (dune (>= 1.10))
  )
  (tags (clib:nlopt))
)
