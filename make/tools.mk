# 🔧 Installation des outils systeme
install-system-tools:
	$(SEPARATOR)
	$(INFO) Installation des outils systeme...
	@powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList 'choco install -y git make'"
	$(SUCCESS) Installation terminee
	$(SEPARATOR)

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