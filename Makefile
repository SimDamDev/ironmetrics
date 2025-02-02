# 🛠️ Variables
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
# Ctrl + Alt + I -> make init-repo (Initialisation GitHub)
# Ctrl + Alt + G -> make install-gitleaks (Installation GitLeaks)

.PHONY: all test lint security-check autofix panic stats deploy gendoc explain progress quickpush security-full toggle-beta toggle-signatures init-git init-docs install-deps init-project-structure install-gitleaks

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

# 🚀 Initialisation du dépôt GitHub
init-repo: init-git
	$(SEPARATOR)
	$(INFO) Configuration du dépôt GitHub...
	@if not exist .git\config ($(ERROR) Git n'est pas initialise && exit /b 1)
	@$(GIT) config --local user.name "SimDamDev" || ($(ERROR) Impossible de configurer le nom d'utilisateur && exit /b 1)
	@$(GIT) config --local user.email "contact@simdam.ch" || ($(ERROR) Impossible de configurer l'email && exit /b 1)
	@$(GIT) remote -v | findstr origin >nul || ($(INFO) Ajout du remote origin... && $(GIT) remote add origin https://github.com/SimDamDev/ironmetrics.git)
	@$(GIT) branch -M main
	@$(GIT) add .
	@$(GIT) commit -m "Initial commit" || $(SUCCESS) Rien a commiter
	@$(GIT) push -u origin main || ($(WARNING) Impossible de pousser vers GitHub, verifiez vos droits d'acces)
	$(SUCCESS) Dépôt GitHub configuré
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
	-$(PYTHON) -m bandit -r . > build.log 2>&1
	$(INFO) Resume de l'audit :
	@echo "$(SYMBOL_INFO) Securite du code :"
	@findstr /C:"No issues identified" build.log >nul && echo "  $(SYMBOL_SUCCESS) Aucun probleme trouve" || echo "  $(SYMBOL_ERROR) Problemes de securite detectes"
	@del build.log 2>nul
	$(SEPARATOR)

# 🛡️ Verification complete de la securite
security-full: install-deps init-git
	$(SEPARATOR)
	$(INFO) Execution de l'audit de securite complet...
	$(SECTION_START)
	$(INFO) 1. Analyse statique du code avec Bandit...
	-$(PYTHON) -m bandit -r . -ll -v > build.log 2>&1
	$(SECTION_START)
	$(INFO) 2. Verification des dependances avec Safety...
	-$(PYTHON) -m safety scan --output screen --full-report >> build.log 2>&1
	$(SECTION_START)
	$(INFO) 3. Verification des secrets (optionnel)...
	@where gitleaks >nul 2>nul && ( \
		$(INFO) Analyse avec GitLeaks... && \
		gitleaks detect --no-git >> build.log 2>&1 \
	) || ( \
		$(INFO) Pour une analyse complete des secrets, installez GitLeaks : && \
		echo "  1. Ouvrez PowerShell en tant qu'administrateur" && \
		echo "  2. Executez : choco install gitleaks -y" && \
		echo "  3. Relancez la commande security-full" \
	)
	$(SEPARATOR)
	$(INFO) Resume de l'analyse :
	@echo "$(SYMBOL_INFO) Analyse statique (Bandit) :"
	@findstr /C:"No issues identified" build.log >nul && echo "  $(SYMBOL_SUCCESS) Aucun probleme trouve" || echo "  $(SYMBOL_ERROR) Problemes detectes"
	@echo "$(SYMBOL_INFO) Dependances (Safety) :"
	@findstr /C:"No known security vulnerabilities found" build.log >nul && echo "  $(SYMBOL_SUCCESS) Aucune vulnerabilite" || echo "  $(SYMBOL_ERROR) Vulnerabilites detectees"
	@echo "$(SYMBOL_INFO) Secrets (GitLeaks) :"
	@where gitleaks >nul 2>nul && ( \
		findstr /C:"no leaks found" build.log >nul && echo "  $(SYMBOL_SUCCESS) Aucune fuite detectee" || echo "  $(SYMBOL_ERROR) Fuites potentielles detectees" \
	) || echo "  $(SYMBOL_SKIP) Non verifie (GitLeaks non installe)"
	@del build.log 2>nul
	$(SEPARATOR)

# 🧹 Verification du code
lint: install-deps
	$(SEPARATOR)
	$(INFO) Verification du code...
	@where $(LINTER) >nul 2>nul || ($(ERROR) pylint n'est pas trouve dans le PATH && exit /b 1)
	-$(LINTER) src/ > build.log 2>&1
	$(INFO) Resume de l'analyse :
	@echo "[>] Qualite du code :"
	@findstr /C:"Your code has been rated at 10.00/10" build.log >nul && echo "  [+] Code parfait (10/10)" || echo "  [!] Ameliorations possibles"
	@del build.log 2>nul
	$(SEPARATOR)

# 🧪 Tests
test: install-deps init-project-structure
	$(SEPARATOR)
	$(INFO) Execution des tests...
	@$(PIP) install --quiet pytest
	-$(PYTHON) -m pytest > build.log 2>&1
	$(INFO) Resume des tests :
	@echo "[>] Tests unitaires :"
	@findstr /C:"failed" build.log >nul && echo "  [!] Certains tests ont echoue" || echo "  [+] Tous les tests ont reussi"
	@findstr /C:"no tests ran" build.log >nul && echo "  [-] Aucun test execute"
	@del build.log 2>nul
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
autofix:
	@echo "[INFO] Configuration du PATH Python..."
	@if not exist $(TEMP_DIR) mkdir $(TEMP_DIR)
	-@set "PYTHONPATH=$(PYTHONPATH)" 2>nul
	@echo "[INFO] Mise a jour de pip..."
	-@$(PIP) install --upgrade pip > $(TEMP_DIR)/build.log 2>nul || echo "[WARN] Erreur lors de la mise a jour de pip"
	@echo "[INFO] Installation des dependances Python..."
	-@$(PIP) install -r requirements.txt >> $(TEMP_DIR)/build.log 2>nul || echo "[WARN] Erreur lors de l'installation des dependances Python"
	@echo "[INFO] Installation des dependances JavaScript..."
	-@npm install >> $(TEMP_DIR)/build.log 2>nul || echo "[WARN] Erreur lors de l'installation des dependances JavaScript"
	@echo "[INFO] Installation des dependances Java..."
	-@where java >nul 2>nul && ( \
		echo "[INFO] Installation de google-java-format..." && \
		npm install google-java-format >> $(TEMP_DIR)/build.log 2>nul \
	) || echo "[WARN] Java non trouve, google-java-format non installe"
	@echo "[INFO] Installation des dependances Rust..."
	-@where rustc >nul 2>nul && ( \
		echo "[INFO] Installation de rustfmt..." && \
		rustup component add rustfmt >> $(TEMP_DIR)/build.log 2>nul \
	) || echo "[WARN] Rust non trouve, rustfmt non installe"
	@echo "=========================================="
	@echo "=========================================="
	@echo "[INFO] Correction automatique du code..."
	@echo "----------------------------------------"
	@echo "[INFO] 1. Installation des outils de formatage..."
	-@$(PIP) install --quiet autopep8 black > $(TEMP_DIR)/build.log 2>nul || echo "[WARN] Erreur lors de l'installation de autopep8/black"
	-@npm install -g prettier >> $(TEMP_DIR)/build.log 2>nul || echo "[WARN] Erreur lors de l'installation de prettier"
	@echo "----------------------------------------"
	@echo "[INFO] 2. Formatage du code..."
	@echo "[>] Fichiers Python :"
	-@$(PYTHON) -m black --verbose . > $(TEMP_DIR)/python.log 2>&1
	-@type $(TEMP_DIR)\python.log >> $(TEMP_DIR)\build.log
	-@findstr /i /c:"reformatted" $(TEMP_DIR)\python.log >nul 2>nul && ( \
		for /f "tokens=2 delims= " %%i in ('findstr /i /c:"reformatted" $(TEMP_DIR)\python.log') do @echo "  $(SYMBOL_SUCCESS) %%~nxi" \
	) || echo "[INFO] Aucun fichier Python trouve"
	@echo "[>] Fichiers JavaScript :"
	-@npx prettier --write "**/*.{js,jsx,ts,tsx}" >> $(TEMP_DIR)/build.log 2>nul || echo "[INFO] Aucun fichier JavaScript trouve"
	@echo "[>] Fichiers HTML/CSS :"
	-@npx prettier --write "**/*.{html,css,scss}" >> $(TEMP_DIR)/build.log 2>nul || echo "[INFO] Aucun fichier HTML/CSS trouve"
	@echo "[>] Fichiers Java :"
	-@where java >nul 2>nul && npx google-java-format -r ./**/*.java >> $(TEMP_DIR)/build.log 2>nul || echo "[INFO] Aucun fichier Java trouve"
	@echo "[>] Fichiers Rust :"
	-@where rustc >nul 2>nul && rustfmt **/*.rs >> $(TEMP_DIR)/build.log 2>nul || echo "[INFO] Aucun fichier Rust trouve"
	@echo "----------------------------------------"
	@echo "[INFO] Resume du formatage :"
	@echo "[>] Fichiers modifies :"
	-@powershell -Command " \
		$$modified = $$false; \
		if (Test-Path $(TEMP_DIR)/python.log) { \
			$$files = Select-String -Path $(TEMP_DIR)/python.log -Pattern 'reformatted (.+)' | ForEach-Object { $$_.Matches.Groups[1].Value }; \
			if ($$files) { \
				$$modified = $$true; \
				$$files | ForEach-Object { Write-Host ('  $(SYMBOL_SUCCESS) ' + (Split-Path $$_ -Leaf)) } \
			} \
		} \
		if (-not $$modified) { \
			Write-Host '  $(SYMBOL_SUCCESS) Aucun fichier modifie' \
		} \
	"
	-@rmdir /s /q $(TEMP_DIR) >nul 2>nul || ver >nul
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
	-$(GIT) shortlog -sn --all > build.log 2>&1
	$(INFO) Resume des statistiques :
	@echo "[>] Contributions :"
	@findstr /C:"No output" build.log >nul && echo "  [-] Pas d'historique disponible" || (type build.log && echo "  [+] Historique affiche")
	@del build.log 2>nul
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
	-$(GIT) log --oneline --graph --all > build.log 2>&1
	$(INFO) Resume de la progression :
	@echo "[>] Historique des commits :"
	@findstr /C:"fatal: your current branch" build.log >nul && echo "  [-] Pas d'historique Git" || (type build.log && echo "  [+] Historique affiche")
	@del build.log 2>nul
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

# 🔧 Installation de GitLeaks
install-gitleaks:
	$(SEPARATOR)
	$(INFO) Installation de GitLeaks...
	@powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList 'choco install -y gitleaks --no-progress'" || ( \
		$(ERROR) Impossible d'installer GitLeaks && \
		$(INFO) Pour installer manuellement : && \
		$(INFO) 1. Ouvrez PowerShell en tant qu'administrateur && \
		$(INFO) 2. Executez : choco install gitleaks -y && \
		exit /b 1 \
	)
	$(SUCCESS) GitLeaks installe avec succes
	$(SEPARATOR)

# Nettoyage des fichiers temporaires
clean:
	$(SEPARATOR)
	$(INFO) Nettoyage des fichiers temporaires...
	-@if exist $(TEMP_DIR) rmdir /s /q $(TEMP_DIR) >nul 2>nul
	$(SUCCESS) Nettoyage termine
	$(SEPARATOR) 