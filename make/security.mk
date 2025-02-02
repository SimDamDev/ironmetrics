# 🔍 Verification de la securite
security-check: install-deps init-git
	$(SEPARATOR)
	$(INFO) Execution de l'audit de securite basique...
	@if not exist $(TEMP_DIR) mkdir $(TEMP_DIR)
	-$(PYTHON) -m bandit -r . > $(TEMP_DIR)/security.log 2>&1
	$(INFO) Resume de l'audit :
	@echo "[>] Securite du code :"
	@powershell -Command " \
		if (Test-Path '$(TEMP_DIR)/security.log') { \
			$$content = Get-Content '$(TEMP_DIR)/security.log' -Raw; \
			if ($$content -match 'No issues identified') { \
				Write-Host '  [+] Aucun probleme trouve' \
			} else { \
				Write-Host '  [!] Problemes de securite detectes'; \
				Write-Host ''; \
				Write-Host $$content; \
			} \
		} else { \
			Write-Host '  [!] Erreur lors de l''analyse de securite' \
		} \
	"
	-@rmdir /s /q $(TEMP_DIR) >nul 2>nul || ver >nul
	$(SEPARATOR)

# 🛡️ Verification complete de la securite
security-full: install-deps init-git
	$(SEPARATOR)
	$(INFO) Execution de l'audit de securite complet...
	@if not exist $(TEMP_DIR) mkdir $(TEMP_DIR)
	$(SECTION_START)
	$(INFO) 1. Analyse statique du code avec Bandit...
	-$(PYTHON) -m bandit -r . -ll -v > $(TEMP_DIR)/security_full.log 2>&1
	$(SECTION_START)
	$(INFO) 2. Verification des dependances avec Safety...
	-$(PYTHON) -m safety scan --output screen --full-report >> $(TEMP_DIR)/security_full.log 2>&1
	$(SECTION_START)
	$(INFO) 3. Verification des secrets (optionnel)...
	@powershell -Command " \
		$$gitleaks = Get-Command gitleaks -ErrorAction SilentlyContinue; \
		if ($$gitleaks) { \
			Write-Host '[INFO] Analyse avec GitLeaks...'; \
			& gitleaks detect --no-git >> '$(TEMP_DIR)/security_full.log' 2>&1; \
		} else { \
			Write-Host '[INFO] Pour une analyse complete des secrets, installez GitLeaks :'; \
			Write-Host '  1. Ouvrez PowerShell en tant qu''administrateur'; \
			Write-Host '  2. Executez : choco install gitleaks -y'; \
			Write-Host '  3. Relancez la commande security-full'; \
		} \
	"
	$(SEPARATOR)
	$(INFO) Resume de l'analyse :
	@powershell -Command " \
		if (Test-Path '$(TEMP_DIR)/security_full.log') { \
			$$content = Get-Content '$(TEMP_DIR)/security_full.log' -Raw; \
			Write-Host '[>] Analyse statique (Bandit) :'; \
			if ($$content -match 'No issues identified') { \
				Write-Host '  [+] Aucun probleme trouve' \
			} else { \
				Write-Host '  [!] Problemes detectes' \
			}; \
			Write-Host '[>] Dependances (Safety) :'; \
			if ($$content -match 'No known security vulnerabilities found') { \
				Write-Host '  [+] Aucune vulnerabilite' \
			} else { \
				Write-Host '  [!] Vulnerabilites detectees' \
			}; \
			Write-Host '[>] Secrets (GitLeaks) :'; \
			$$gitleaks = Get-Command gitleaks -ErrorAction SilentlyContinue; \
			if ($$gitleaks) { \
				if ($$content -match 'no leaks found') { \
					Write-Host '  [+] Aucune fuite detectee' \
				} else { \
					Write-Host '  [!] Fuites potentielles detectees' \
				} \
			} else { \
				Write-Host '  [-] Non verifie (GitLeaks non installe)' \
			}; \
			Write-Host ''; \
			Write-Host $$content; \
		} else { \
			Write-Host '  [!] Erreur lors de l''analyse de securite' \
		} \
	"
	-@rmdir /s /q $(TEMP_DIR) >nul 2>nul || ver >nul
	$(SEPARATOR) 