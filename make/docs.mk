# 📝 Generation de documentation
init-docs:
	$(SEPARATOR)
	$(INFO) Initialisation de la documentation...
	@if not exist docs\source mkdir docs\source
	@if not exist docs\source\conf.py (cd docs\source && sphinx-quickstart -q -p IronMetrics -a "Dev" -v 1.0 -r 1.0) else ($(SUCCESS) Documentation deja configuree)
	$(SEPARATOR)

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