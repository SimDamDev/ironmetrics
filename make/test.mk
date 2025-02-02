# 🧹 Verification du code
lint: install-deps
	$(SEPARATOR)
	$(INFO) Verification du code...
	@where $(LINTER) >nul 2>nul || ($(ERROR) pylint n'est pas trouve dans le PATH && exit /b 1)
	@if not exist $(TEMP_DIR) mkdir $(TEMP_DIR)
	-$(LINTER) src/ > $(TEMP_DIR)/lint.log 2>&1
	$(INFO) Resume de l'analyse :
	@echo "[>] Qualite du code :"
	@powershell -Command "if (Test-Path '$(TEMP_DIR)/lint.log') { if (Select-String -Path '$(TEMP_DIR)/lint.log' -Pattern 'Your code has been rated at 10.00/10') { Write-Host '  [+] Code parfait (10/10)' } else { Write-Host '  [!] Ameliorations possibles' } }"
	-@rmdir /s /q $(TEMP_DIR) >nul 2>nul || ver >nul
	$(SEPARATOR)

# 🧪 Tests
test: install-deps init-project-structure
	$(SEPARATOR)
	$(INFO) Execution des tests...
	@$(PIP) install --quiet pytest
	@if not exist $(TEMP_DIR) mkdir $(TEMP_DIR)
	-@$(PYTHON) -m pytest > "$(TEMP_DIR)/test.log" 2>&1 || echo "[WARN] Erreurs dans les tests"
	$(INFO) Resume des tests :
	@echo "[>] Tests unitaires :"
	@powershell -Command " \
		if (Test-Path '$(TEMP_DIR)/test.log') { \
			$$content = Get-Content '$(TEMP_DIR)/test.log' -Raw; \
			if ($$content -match 'failed') { \
				Write-Host '  [!] Certains tests ont echoue' \
			} else { \
				Write-Host '  [+] Tous les tests ont reussi' \
			}; \
			if ($$content -match 'no tests ran') { \
				Write-Host '  [-] Aucun test execute' \
			}; \
			if ($$content -match 'collected 0 items') { \
				Write-Host '  [-] Aucun test trouve' \
			}; \
			Write-Host ''; \
			Write-Host $$content; \
		} else { \
			Write-Host '  [!] Erreur l''execution des tests' \
		} \
	"
	-@rmdir /s /q $(TEMP_DIR) >nul 2>nul || ver >nul
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