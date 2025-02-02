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

# 🚀 Deploiement
deploy: init-git
	$(SEPARATOR)
	$(INFO) Deploiement...
	@where docker >nul 2>nul || ($(ERROR) Docker n'est pas trouve dans le PATH && exit /b 1)
	@where docker-compose >nul 2>nul || ($(ERROR) Docker Compose n'est pas trouve dans le PATH && exit /b 1)
	-$(GIT) pull origin main && docker-compose up -d --build
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