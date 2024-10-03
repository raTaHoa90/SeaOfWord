components {
  id: "letters_cr_line"
  component: "/main/letter_cr/letters_cr_line.script"
}
embedded_components {
  id: "circle"
  type: "sprite"
  data: "default_animation: \"arc-full\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "size {\n"
  "  x: 588.0\n"
  "  y: 588.0\n"
  "}\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/main/game-sprites.atlas\"\n"
  "}\n"
  ""
  position {
    z: 0.1
  }
  scale {
    x: 0.5
    y: 0.5
  }
}
embedded_components {
  id: "letter_cr_factory"
  type: "factory"
  data: "prototype: \"/main/letter_cr/letter_circle.go\"\n"
  ""
}
