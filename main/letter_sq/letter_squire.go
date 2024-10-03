components {
  id: "letter_squire"
  component: "/main/letter_sq/letter_squire.script"
}
embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"squire\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "size {\n"
  "  x: 144.0\n"
  "  y: 144.0\n"
  "}\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/main/game-sprites.atlas\"\n"
  "}\n"
  ""
  scale {
    x: 0.5
    y: 0.5
  }
}
embedded_components {
  id: "label_letter"
  type: "label"
  data: "size {\n"
  "  x: 70.0\n"
  "  y: 60.0\n"
  "}\n"
  "color {\n"
  "  x: 0.0\n"
  "  y: 0.0\n"
  "  z: 0.0\n"
  "}\n"
  "outline {\n"
  "  x: 1.0\n"
  "  y: 1.0\n"
  "  z: 1.0\n"
  "}\n"
  "shadow {\n"
  "  x: 1.0\n"
  "  y: 1.0\n"
  "  z: 1.0\n"
  "}\n"
  "text: \"\\320\\250\"\n"
  "font: \"/assets/VAG_World.font\"\n"
  "material: \"/builtins/fonts/label-df.material\"\n"
  ""
  position {
    x: 1.0
    y: 7.0
    z: 0.1
  }
}
