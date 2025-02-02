# 🛠️ Variables
PYTHON := py
PIP := $(PYTHON) -m pip
LINTER := pylint
SECURITY := bandit
TEST_RUNNER := pytest
GIT := git

# Styles pour le terminal
SEPARATOR := @echo "=========================================="
INFO := @echo [INFO]
SUCCESS := @echo [SUCCESS]
WARNING := @echo [ATTENTION]
ERROR := @echo [ERREUR]

# Variables pour la configuration
CONFIG_FILE := config.mk
BETA_MODE := $(shell if exist $(CONFIG_FILE) (findstr "BETA_MODE=1" $(CONFIG_FILE)) else (echo))
SIGNATURES_MODE := $(shell if exist $(CONFIG_FILE) (findstr "SIGNATURES=1" $(CONFIG_FILE)) else (echo))

# 🔧 Installation des outils systeme
install-system-tools:
	$(SEPARATOR)
	$(INFO) Installation des outils systeme...
	@powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList 'choco install -y git make'"
	$(SUCCESS) Installation terminee
	$(SEPARATOR)

# Verification de l'existence des commandes
HAVE_GIT := $(shell where $(GIT) 2> NUL)
HAVE_PYTHON := $(shell where $(PYTHON) 2> NUL)

# 📚 Documentation des raccourcis
# 🤖 Raccourcis IA Cursor :
# Ctrl + I -> Ouvrir le Composer IA
# Ctrl + L -> Ouvrir le Chat IA
# Ctrl + Shift + L -> Ajouter le code au contexte
# Ctrl + Shift + K -> Editer le code avec l'IA
# Ctrl + Enter -> Accepter les changements
#
# ⚙️ Raccourcis Make :
# Ctrl + Shift + A -> make autofix (Formatage rapide)
# Ctrl + Alt + Z -> make panic (Reset securise)
# Ctrl + Shift + T -> make test (Tests)
# Ctrl + Shift + R -> make security-check (Audit)
# Ctrl + Alt + H -> make progress (Progression)
# Ctrl + Shift + M -> make stats (Stats projet)
# Ctrl + Alt + P -> make quickpush (Push rapide)
# Ctrl + Alt + D -> make deploy (Deploiement)
# Ctrl + Alt + S -> make security-full (Verification complete)
# Ctrl + Alt + B -> make toggle-beta (BETA_MODE)
# Ctrl + Alt + X -> make toggle-signatures (Signatures)

.PHONY: all test lint security-check autofix panic stats deploy gendoc explain progress quickpush security-full toggle-beta toggle-signatures init-git init-docs install-deps init-project-structure

all: test lint security-check

# 🔧 Installation des dependances
install-deps:
	$(SEPARATOR)
	$(INFO) Configuration du PATH Python...
	@powershell -Command "[Environment]::SetEnvironmentVariable('PATH', [Environment]::GetEnvironmentVariable('PATH', 'User') + ';%APPDATA%\Python\Python313\Scripts', 'User')"
	$(INFO) Mise a jour de pip...
	@$(PYTHON) -m pip install --quiet --upgrade pip
	$(INFO) Installation des dependances Python...
	@$(PIP) install --quiet pytest pylint bandit safety sphinx autopep8 black
	@$(PIP) install --quiet bandit
	@where bandit >nul 2>nul || ($(ERROR) Bandit n'est pas dans le PATH, installation via pip... && $(PIP) install -U bandit)
	$(INFO) Installation des dependances JavaScript...
	@where npm >nul 2>nul && npm install -g prettier || $(WARNING) npm non trouve, prettier non installe
	$(INFO) Installation des dependances Java...
	@where java >nul 2>nul && npm install -g google-java-format || $(WARNING) Java non trouve, google-java-format non installe
	$(INFO) Installation des dependances Rust...
	@where rustc >nul 2>nul && rustup component add rustfmt || $(WARNING) Rust non trouve, rustfmt non installe
	$(SEPARATOR)

# 🔧 Initialisation
init-git:
	$(SEPARATOR)
	$(INFO) Initialisation de Git...
	@where git >nul 2>nul || ($(ERROR) Git n'est pas installe ! Executez 'make install-system-tools' && exit /b 1)
	@if not exist .git ($(GIT) init) else ($(SUCCESS) Git deja initialise)
	$(SEPARATOR)

init-docs:
	$(SEPARATOR)
	$(INFO) Initialisation de la documentation...
	@if not exist docs\source mkdir docs\source
	@if not exist docs\source\conf.py (cd docs\source && sphinx-quickstart -q -p IronMetrics -a "Dev" -v 1.0 -r 1.0) else ($(SUCCESS) Documentation deja configuree)
	$(SEPARATOR)

# 🔍 Verification de la securite
security-check: install-deps init-git
	$(SEPARATOR)
	$(INFO) Execution de l'audit de securite basique...
	-$(PYTHON) -m bandit -r .
	$(SEPARATOR)

# 🛡️ Verification complete de la securite
security-full: install-deps init-git
	$(SEPARATOR)
	$(INFO) Execution de l'audit de securite complet...
	@where bandit >nul 2>nul || ($(ERROR) bandit n'est pas trouve dans le PATH && exit /b 1)
	-$(PYTHON) -m bandit -r . -ll
	$(INFO) Verification des dependances...
	@where safety >nul 2>nul || ($(ERROR) safety n'est pas trouve dans le PATH && exit /b 1)
	-$(PYTHON) -m safety check
	$(SEPARATOR)

# 🧹 Verification du code
lint: install-deps
	$(SEPARATOR)
	$(INFO) Verification du code...
	@where $(LINTER) >nul 2>nul || ($(ERROR) pylint n'est pas trouve dans le PATH && exit /b 1)
	-$(LINTER) src/
	$(SEPARATOR)

# 🧪 Tests
test: install-deps init-project-structure
	$(SEPARATOR)
	$(INFO) Execution des tests...
	@$(PIP) install --quiet pytest
	-$(PYTHON) -m pytest
	$(SEPARATOR)

# 🏗️ Initialisation de la structure du projet
init-project-structure:
	$(SEPARATOR)
	$(INFO) Verification de la structure du projet...
	@if not exist src ( \
		$(INFO) Creation du dossier src... && \
		mkdir src && \
		powershell -Command "Set-Content -Path 'src/__init__.py' -Value '# Fichier principal du projet'" && \
		$(SUCCESS) Dossier src cree \
	)
	@if not exist tests ( \
		$(INFO) Creation du dossier tests... && \
		mkdir tests && \
		powershell -Command "Set-Content -Path 'tests/__init__.py' -Value 'import pytest'" && \
		powershell -Command "$$content = @('def test_example():', '    assert True'); Set-Content -Path 'tests/test_example.py' -Value $$content" && \
		$(SUCCESS) Dossier tests cree avec un test exemple \
	)
	@if not exist requirements.txt ( \
		$(INFO) Creation du fichier requirements.txt... && \
		powershell -Command "$$content = @('pytest', 'pylint', 'bandit', 'safety', 'sphinx', 'autopep8', 'black'); Set-Content -Path 'requirements.txt' -Value $$content" && \
		$(SUCCESS) Fichier requirements.txt cree \
	)
	@if not exist README.md ( \
		$(INFO) Creation du fichier README.md... && \
		powershell -Command "$$content = @('# IronMetrics', '', '## Installation', '', '```bash', 'pip install -r requirements.txt', '```'); Set-Content -Path 'README.md' -Value $$content" && \
		$(SUCCESS) Fichier README.md cree \
	)
	$(SEPARATOR)

# 🚀 Deploiement
deploy: init-git
	$(SEPARATOR)
	$(INFO) Deploiement...
	@where docker >nul 2>nul || ($(ERROR) Docker n'est pas trouve dans le PATH && exit /b 1)
	@where docker-compose >nul 2>nul || ($(ERROR) Docker Compose n'est pas trouve dans le PATH && exit /b 1)
	-$(GIT) pull origin main && docker-compose up -d --build
	$(SEPARATOR)

# 🤖 Correction automatique avec IA
autofix: install-deps
	$(SEPARATOR)
	$(INFO) Correction automatique du code avec IA...
	@where cursor >nul 2>nul || ($(ERROR) Cursor n'est pas trouve dans le PATH && exit /b 1)
	
	$(INFO) Pour utiliser l'IA de Cursor :
	@echo "  * Ctrl + I : Ouvrir le Composer"
	@echo "  * Ctrl + Shift + K : Editer le code selectionne"
	@echo "  * Ctrl + Enter : Accepter les changements"
	$(SEPARATOR)
	
	$(INFO) Application du formatage basique...
	
	$(INFO) Fichiers Python :
	@where autopep8 >nul 2>nul || ($(ERROR) autopep8 n'est pas trouve dans le PATH && exit /b 1)
	-$(PYTHON) -m autopep8 --in-place --aggressive --recursive .
	
	$(INFO) Fichiers JavaScript :
	@where prettier >nul 2>nul || ($(WARNING) prettier n'est pas trouve dans le PATH)
	-npx prettier --write "**/*.{js,jsx,ts,tsx}" 2>nul || $(WARNING) Pas de fichiers JS trouves
	
	$(INFO) Fichiers HTML/CSS :
	-npx prettier --write "**/*.{html,css,scss}" 2>nul || $(WARNING) Pas de fichiers HTML/CSS trouves
	
	$(INFO) Fichiers Java :
	@where java >nul 2>nul || ($(WARNING) java n'est pas trouve dans le PATH)
	-npx google-java-format -r ./**/*.java 2>nul || $(WARNING) Pas de fichiers Java trouves
	
	$(INFO) Fichiers Rust :
	@where rustc >nul 2>nul || ($(WARNING) rustc n'est pas trouve dans le PATH)
	-rustfmt **/*.rs 2>nul || $(WARNING) Pas de fichiers Rust trouves
	
	$(SEPARATOR)
	$(INFO) Fichiers corriges :
	@dir /s /b *.{py,js,jsx,ts,tsx,html,css,scss,java,rs} 2>nul || $(WARNING) Aucun fichier trouve
	$(SUCCESS) Formatage termine
	$(SEPARATOR)

# ⚠️ Mode Panique (Securise)
panic: init-git
	$(SEPARATOR)
	$(WARNING) ATTENTION: Cette commande va reinitialiser les changements non sauvegardes
	$(INFO) Les fichiers suivants seront affectes :
	-$(GIT) status --porcelain
	$(SEPARATOR)
	$(INFO) Les fichiers suivants sont proteges et ne seront PAS affectes :
	@echo "  * Makefile"
	@echo "  * .gitignore"
	@echo "  * README.md"
	$(SEPARATOR)
	@echo "Voulez-vous continuer ? [y/N] " && set /p CONTINUE= && if /i "!CONTINUE!"=="y" ( \
		$(GIT) stash push -m "panic_backup" -- . ":(exclude)Makefile" ":(exclude).gitignore" ":(exclude)README.md" && \
		$(SUCCESS) Les changements ont ete sauvegardes dans une stash 'panic_backup' && \
		$(INFO) Pour les recuperer : git stash pop \
	)
	$(SEPARATOR)

# 📊 Statistiques
stats: init-git
	$(SEPARATOR)
	$(INFO) Statistiques du projet...
	-$(GIT) shortlog -sn --all || $(WARNING) Pas d'historique Git disponible
	$(SEPARATOR)

# 📝 Generation de documentation
gendoc: init-docs
	$(SEPARATOR)
	$(INFO) Generation de la documentation...
	@where sphinx-build >nul 2>nul || ($(ERROR) Sphinx n'est pas installe ! && exit /b 1)
	-sphinx-build -b html docs/source docs/build
	$(SEPARATOR)

# 🔍 Explication du code
explain:
	$(SEPARATOR)
	$(INFO) Generation des explications...
	@where cursor >nul 2>nul || ($(ERROR) Cursor CLI n'est pas installe ! && exit /b 1)
	-cursor explain
	$(SEPARATOR)

# 📈 Progression
progress: init-git
	$(SEPARATOR)
	$(INFO) Progression du projet...
	-$(GIT) log --oneline --graph --all || $(WARNING) Pas d'historique Git disponible
	$(SEPARATOR)

# 🚀 Push rapide
quickpush: init-git
	$(SEPARATOR)
	$(INFO) Push rapide...
	-$(GIT) add . && $(GIT) commit -m "Quick update" && $(GIT) push || $(WARNING) Erreur lors du push
	$(SEPARATOR)

# 🔑 Toggle Beta Mode
toggle-beta:
	$(SEPARATOR)
	$(INFO) Modification du mode BETA...
	@if exist $(CONFIG_FILE) ( \
		findstr /C:"BETA_MODE=1" $(CONFIG_FILE) >nul && ( \
			$(INFO) Desactivation du mode BETA... && \
			powershell -Command "(Get-Content $(CONFIG_FILE)) -replace 'BETA_MODE=1', 'BETA_MODE=0' | Set-Content $(CONFIG_FILE)" && \
			$(SUCCESS) Mode BETA desactive \
		) || ( \
			$(INFO) Activation du mode BETA... && \
			powershell -Command "(Get-Content $(CONFIG_FILE)) -replace 'BETA_MODE=0', 'BETA_MODE=1' | Set-Content $(CONFIG_FILE)" && \
			$(SUCCESS) Mode BETA active \
		) \
	) else ( \
		$(INFO) Creation du fichier de configuration... && \
		echo BETA_MODE=1 > $(CONFIG_FILE) && \
		$(SUCCESS) Mode BETA active \
	)
	$(SEPARATOR)

# 🔓 Toggle Signatures
toggle-signatures: init-git
	$(SEPARATOR)
	$(INFO) Modification des signatures...
	@if exist $(CONFIG_FILE) ( \
		findstr /C:"SIGNATURES=1" $(CONFIG_FILE) >nul && ( \
			$(INFO) Desactivation des signatures... && \
			powershell -Command "(Get-Content $(CONFIG_FILE)) -replace 'SIGNATURES=1', 'SIGNATURES=0' | Set-Content $(CONFIG_FILE)" && \
			$(GIT) config commit.gpgsign false && \
			$(SUCCESS) Signatures desactivees \
		) || ( \
			$(INFO) Activation des signatures... && \
			powershell -Command "(Get-Content $(CONFIG_FILE)) -replace 'SIGNATURES=0', 'SIGNATURES=1' | Set-Content $(CONFIG_FILE)" && \
			$(GIT) config commit.gpgsign true && \
			$(SUCCESS) Signatures activees \
		) \
	) else ( \
		$(INFO) Creation du fichier de configuration... && \
		echo SIGNATURES=1 >> $(CONFIG_FILE) && \
		$(GIT) config commit.gpgsign true && \
		$(SUCCESS) Signatures activees \
	)
	$(SEPARATOR) 