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