SHELL=/bin/zsh


.DEFAULT: build

BUILD_DIR = out
ICON_DIR = icons


BIN_DIR          := exe
OCI_ICON_REPO    := https://github.com/opencontainers/artwork.git
OCI_REPO_DIR     := $(BUILD_DIR)/oci/artwork
OCI_ICON_SRC_DIR := $(OCI_REPO_DIR)/icons
ICONS_BUILD_DIR  := $(BUILD_DIR)/$(ICON_DIR)

PUML_ICONS_DIR   := $(BUILD_DIR)/$(ICON_DIR)

DIRS := $(BUILD_DIR) $(BIN_DIR) $(ICON_DIR) $(OCI_REPO_DIR) $(ICONS_BUILD_DIR)

PLANTUML_JAR =
ICON_GRAY_LEVEL = 4
ICON_COMPRESS = z
PNG_ICON_HEIGHT = 64

export PLANTUML_JAR

$(DIRS) : ; mkdir -p $@

CREATE_SPRITE = $(BIN_DIR)/create_sprite.sh


# Need this directory
_ICONS := $(wildcard $(OCI_ICON_SRC_DIR)/*.svg)
ifeq ($(strip $(_ICONS)),)
$(shell mkdir -p $(OCI_REPO_DIR))
$(shell git clone -b main --depth 1 --single-branch $(OCI_ICON_REPO) $(OCI_REPO_DIR))
$(shell rm -rf $(OCI_REPO_DIR)/.git/ )
# Fix a bad filename
$(shell ( mv '$(OCI_ICON_SRC_DIR)/oci_icon_key vault.svg' "$(OCI_ICON_SRC_DIR)/oci_icon_key_vault.svg" 2>/dev/null ) || true )
$(foreach fil2,$(shell ls $(OCI_ICON_SRC_DIR)/*.svg),$(shell cp $(fil2) $(subst _icon,,$(fil2))))
endif


define FILE_LIST
$(foreach fil2,$(addsuffix $(1),$(addprefix $(2),$(foreach fil,$(notdir $(wildcard $(OCI_ICON_SRC_DIR)/*.svg)),$(subst .svg,,$(fil))))),$(subst _icon,,$(fil2)))
endef


# $(call FILE_LIST,suffix,prefix)
SVG_ICONS   = $(call FILE_LIST,.svg,$(OCI_ICON_SRC_DIR)/)
PNG_ICONS   = $(call FILE_LIST,.png,$(ICONS_BUILD_DIR)/)
PUML_ICONS  = $(call FILE_LIST,.puml,$(ICONS_BUILD_DIR)/)
FINAL_ICONS = $(call FILE_LIST,.puml,$(ICON_DIR)/)


$(OCI_ICON_SRC_DIR)/%.svg: | $(OCI_ICON_SRC_DIR)
	cp $(subst oci_,oci_icon_,$@) $@

$(ICONS_BUILD_DIR)/%.png: $(OCI_ICON_SRC_DIR)/%.svg | $(ICONS_BUILD_DIR)
	rsvg-convert -a -b white -h $(PNG_ICON_HEIGHT) $< > $@

$(ICONS_BUILD_DIR)/%.puml: $(ICONS_BUILD_DIR)/%.png | $(ICONS_BUILD_DIR)
	$(CREATE_SPRITE) $<


$(ICON_DIR)/%.puml: $(ICONS_BUILD_DIR)/%.puml | $(ICON_DIR)
	cp $< $@


.PHONY: build clean

$(ICON_DIR)/INFO: FORCE | $(ICON_DIR)
	echo "BuildTime=$(shell date +'%Y-%m-%dT%H:%M:%S')" > $@
	echo "VERSION=d8ccfe94471a0236b1d4a3f0f90862c4fe5486ce" >> $@
	echo "SOURCE=$(subst .git,,$(OCI_ICON_REPO))" >> $@

icons.puml: $(FINAL_ICONS)
	echo "@startuml test" > $@
	echo "title Icon List" >> $@
	echo "!define ICON_URL https://raw.githubusercontent.com/ThatGerber/plantuml-oci-icons/main/icons" >> $@
	for i in $(subst $(ICON_DIR)/,,$(wildcard $(ICON_DIR)/*.puml)); do \
		echo "!include ICON_URL/$$i" >> $@; \
	done
	echo "listsprites" >> $@
	echo "@enduml" >> $@


build: $(ICON_DIR)/INFO $(FINAL_ICONS) icons.puml
clean:
	rm -rf \
		$(BUILD_DIR) \
		icons.puml

FORCE: ;
