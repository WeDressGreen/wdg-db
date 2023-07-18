########################################
#	Informations
########################################
NOW := $(shell date +"%Y-%m-%dT%H:%M:%S%z")
VERSION ?= $(shell cat ./VERSION)

HS_A := sha1
HS_T := $(shell which sha1sum || which shasum)

I_ST := init
U_ST := update

########################################
#	Outputs
########################################
OUTDIR := ./dist

FUNCTION_FILE := $(OUTDIR)/init_fct.sql

I_FL := $(OUTDIR)/$(I_ST)-$(VERSION).sql
I_HS := $(I_FL).$(HS_A)

U_FL := $(OUTDIR)/$(U_ST)-$(VERSION).sql
U_HS := $(U_FL).$(HS_A)

########################################
#	Inputs
########################################
COREDIR := ./core

pre_init := $(COREDIR)/_pre_init.sql

init := 								\
	$(COREDIR)/ddl/create_tables.sql		\
	$(COREDIR)/ddl/initial_data.sql

init_views := 							\
	$(COREDIR)/ddl/create_mat_views.sql	\
	$(COREDIR)/ddl/create_views.sql

fixs := $(shell find -L $(COREDIR)/fixs/current -name '*.sql' | sort)

funcs_drop := $(COREDIR)/funcs/_pre_drop.sql
funcs := $(shell find $(COREDIR)/funcs -name '*.sql' | grep -v '_pre_drop.sql' | sort)

########################################
#	Build
########################################
clean:
	@echo "Cleaning $(OUTDIR)"
	@rm -fr $(OUTDIR)
	@echo "Cleaning $(COREDIR)/init.sql"
	@rm -fr $(COREDIR)/init.sql
	@echo "Cleaning $(COREDIR)/update.sql"
	@rm -fr $(COREDIR)/update.sql
	@echo "Cleaning docker unused"
	@docker system prune -a
.PHONY: clean

$(I_HS): $(init) $(funcs_drop) $(funcs) $(init_views)
	@mkdir -p $(OUTDIR)
	@echo "[$(I_ST)] Generating hash: $(HS_A)"
	@cat $^ | $(HS_T) | cut -f1 -d ' ' > $(I_HS)

$(I_FL): $(I_HS) $(pre_init) $(init) $(funcs_drop) $(funcs) $(init_views)

ifeq ("$(VERSION)", "")
	@echo "Build failed, no valid version provided!"
else
	@mkdir -p $(OUTDIR)
	$(eval $@_hash=$(shell cat $(I_HS)))
	@sed -e "s/{{VERSION}}/$(VERSION)/g" \
		-e "s/{{SCRIPT_TYPE}}/$(I_ST)/g" \
		-e "s/{{SCRIPT_HASH}}/$($@_hash)/g" \
		-e "s/{{NOW}}/$(NOW)/g" $(pre_init) $(init) $(funcs_drop) $(funcs) $(init_views) > $(I_FL)
	@echo "[$(I_ST)] Builded at $(NOW) ($(HS_A) hash: $($@_hash))"
	@echo "[$(I_ST)] Generated file: $(I_FL) (Version: $(VERSION))"
endif

init: $(I_FL)
.PHONY: init

$(U_HS): $(fixs) $(funcs_drop) $(funcs)
	@mkdir -p $(OUTDIR)
	@echo "[$(U_ST)] Generating hash: $(HS_A)"
	@cat $^ | $(HS_T) | cut -f1 -d ' ' > $(U_HS)

$(U_FL): $(U_HS) $(fixs) $(funcs_drop) $(funcs)

ifeq ("$(VERSION)", "")
	@echo "Build failed, no valid version provided!"
else
	@mkdir -p $(OUTDIR)
	$(eval $@_hash=$(shell cat $(U_HS)))
	@sed -e "s/{{VERSION}}/$(VERSION)/g" \
		-e "s/{{SCRIPT_TYPE}}/$(U_ST)/g" \
		-e "s/{{SCRIPT_HASH}}/$($@_hash)/g" \
		-e "s/{{NOW}}/$(NOW)/g" $(fixs) $(funcs_drop) $(funcs) > $(U_FL)
	@echo "[$(U_ST)] Builded at $(NOW) ($(HS_A) hash: $($@_hash))"
	@echo "[$(U_ST)] Generated file: $(U_FL) (Version: $(VERSION))"
endif

update: $(U_FL)
.PHONY: update

### Funcs file only ###
funcs: $(funcs_drop) $(funcs)
	@mkdir -p $(OUTDIR)
	@echo "Generate funcs file only: $(FUNCTION_FILE)"
	@cat $^ > $(FUNCTION_FILE)
.PHONY: funcs

build:
	@make clean
	@make init
	@cp dist/init-beta-1.0.0.sql core/init.sql
	@docker compose up
.PHONY: build


