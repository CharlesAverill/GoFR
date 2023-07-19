(lang dune 3.7)

(name gofr)

(generate_opam_files true)

(source
 (github CharlesAverill/GoFR))

(authors "Charles Averill")

(license LICENSE)

(documentation https://www.github.com/CharlesAverill/GoFR)

(package
 (name gofr)
 (synopsis "A For Real Go Language")
 (description "A Programming Language controlled by the game Go")
 (depends ocaml dune))
