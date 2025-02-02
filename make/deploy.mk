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
	$(INFO) Configuration du depot GitHub...
	@powershell -Command " \
		Write-Host '[INFO] Verification de la configuration Git...'; \
		if (-not (Test-Path .git\config)) { \
			Write-Host '[ERROR] Git n''est pas initialise'; \
			exit 1; \
		} \
		Write-Host '[INFO] Configuration du nom d''utilisateur...'; \
		git config --local user.name 'SimDamDev'; \
		if (-not $$?) { \
			Write-Host '[ERROR] Impossible de configurer le nom d''utilisateur'; \
			exit 1; \
		} \
		Write-Host '[INFO] Configuration de l''email...'; \
		git config --local user.email 'contact@simdam.ch'; \
		if (-not $$?) { \
			Write-Host '[ERROR] Impossible de configurer l''email'; \
			exit 1; \
		} \
		Write-Host '[INFO] Verification du remote origin...'; \
		$$remote = git remote -v | Select-String 'origin'; \
		if (-not $$remote) { \
			Write-Host '[INFO] Ajout du remote origin...'; \
			git remote add origin https://github.com/SimDamDev/ironmetrics.git; \
		} else { \
			Write-Host '[OK] Remote origin deja configure'; \
		} \
		Write-Host '[INFO] Nettoyage de la configuration de la branche...'; \
		git config --local --unset-all branch.main.remote 2>$$null; \
		git config --local --unset-all branch.main.merge 2>$$null; \
		Write-Host '[INFO] Configuration de la branche principale...'; \
		git branch -M main; \
		Write-Host '[INFO] Verification des modifications...'; \
		$$status = git status --porcelain; \
		if ($$status) { \
			Write-Host '[INFO] Modifications detectees :'; \
			Write-Host $$status; \
			git add .; \
			git commit -m 'Initial commit'; \
		} else { \
			Write-Host '[OK] Rien a commiter'; \
		} \
		Write-Host '[INFO] Configuration de la branche upstream...'; \
		git push -u origin main; \
		if ($$?) { \
			Write-Host '[OK] Depot GitHub configure avec succes'; \
		} else { \
			Write-Host '[WARN] Impossible de pousser vers GitHub, verifiez vos droits d''acces'; \
		} \
	" || $(ERROR) Erreur lors de la configuration du depot
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
	@powershell -Command " \
		Write-Host '[INFO] Verification des modifications...'; \
		$$status = git status --porcelain; \
		if ($$status) { \
			Write-Host '[INFO] Modifications detectees :'; \
			Write-Host $$status; \
			Write-Host ''; \
			git add .; \
			if ($$?) { \
				git commit -m 'Quick update'; \
				if ($$?) { \
					$$branch = git rev-parse --abbrev-ref HEAD; \
					$$upstream = git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$$null; \
					if ($$?) { \
						git push; \
					} else { \
						Write-Host '[INFO] Configuration de la branche upstream...'; \
						git push --set-upstream origin $$branch; \
					} \
					if ($$?) { \
						Write-Host '[OK] Push effectue avec succes' \
					} else { \
						Write-Host '[WARN] Erreur lors du push' \
					} \
				} else { \
					Write-Host '[WARN] Erreur lors du commit' \
				} \
			} else { \
				Write-Host '[WARN] Erreur lors du add' \
			} \
		} else { \
			Write-Host '[INFO] Aucune modification detectee'; \
			Write-Host '[INFO] Verification de commits non pousses...'; \
			$$ahead = git status -sb | Select-String -Pattern 'ahead'; \
			if ($$ahead) { \
				Write-Host '[INFO] Commits locaux detectes, push en cours...'; \
				$$branch = git rev-parse --abbrev-ref HEAD; \
				$$upstream = git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$$null; \
				if ($$?) { \
					git push; \
				} else { \
					Write-Host '[INFO] Configuration de la branche upstream...'; \
					git push --set-upstream origin $$branch; \
				} \
				if ($$?) { \
					Write-Host '[OK] Push effectue avec succes' \
				} else { \
					Write-Host '[WARN] Erreur lors du push' \
				} \
			} else { \
				Write-Host '[INFO] Rien a pousser' \
			} \
		} \
	" || $(WARNING) Erreur lors du push
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