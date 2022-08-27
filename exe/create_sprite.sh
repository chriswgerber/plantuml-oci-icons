#!/usr/bin/env zsh

function create_sprite_file() {
    local source_file="${1}"
    local spritename="$(echo "${source_file}" | sed -e 's/.png$//')"
    local spritenameupper=$(echo "${spritename}" | tr '[:lower:]' '[:upper:]')
    local filename="${spritename}.puml"

    (
        set -v
        java \
          -jar "${PLANTUML_JAR}" \
           -encodesprite 16 \
           "${source_file}"
        echo "!define $spritenameupper(_color)                                 SPRITE_PUT(          $spritenameupper          $spritename, _color)"
        echo "!define $spritenameupper(_color, _scale)                         SPRITE_PUT(          $spritenameupper          $spritename, _color, _scale)"

        echo "!define $spritenameupper(_color, _scale, _alias)                 SPRITE_ENT(  _alias, $spritenameupper,         $spritename, _color, _scale)"
        echo "!define $spritenameupper(_color, _scale, _alias, _shape)         SPRITE_ENT(  _alias, $spritenameupper,         $spritename, _color, _scale, _shape)"
        echo "!define $spritenameupper(_color, _scale, _alias, _shape, _label) SPRITE_ENT_L(_alias, $spritenameupper, _label, $spritename, _color, _scale, _shape)"

        echo "skinparam folderBackgroundColor<<$spritenameupper>> White"
    ) > "${filename}"
}


function main() {
    (
      cd "$(dirname ${1})" || return
      create_sprite_file "$(basename ${1})"
    )
}


main $@
