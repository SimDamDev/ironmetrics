# 🛠️ Variables globales
PYTHON := py
PIP := $(PYTHON) -m pip
LINTER := pylint
SECURITY := bandit
TEST_RUNNER := pytest
GIT := git
TEMP_DIR := temp

# Styles pour le terminal (ASCII simple)
SEPARATOR := @echo "=========================================="
INFO := @echo [INFO]
SUCCESS := @echo [OK]
WARNING := @echo [WARN]
ERROR := @echo [ERR]

# Symboles pour les résumés (ASCII simple)
SYMBOL_SUCCESS := [+]
SYMBOL_ERROR := [!]
SYMBOL_INFO := [>]
SYMBOL_WARNING := [~]
SYMBOL_SKIP := [-]

# Styles pour les sections
SECTION_START := @echo "----------------------------------------"
SECTION_END := @echo "----------------------------------------"

# Variables pour la configuration
CONFIG_FILE := config.mk
BETA_MODE := $(shell if exist $(CONFIG_FILE) (findstr "BETA_MODE=1" $(CONFIG_FILE)) else (echo))
SIGNATURES_MODE := $(shell if exist $(CONFIG_FILE) (findstr "SIGNATURES=1" $(CONFIG_FILE)) else (echo))

# Verification de l'existence des commandes
HAVE_GIT := $(shell where $(GIT) 2> NUL)
HAVE_PYTHON := $(shell where $(PYTHON) 2> NUL) 