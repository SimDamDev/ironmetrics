# 🛠️ IronMetrics Makefile
# Auteur: SimDamDev
# Description: Makefile principal pour le projet IronMetrics

# Inclusion des sous-fichiers
include make/config.mk    # Configuration et variables
include make/tools.mk     # Outils et dépendances
include make/format.mk    # Formatage du code
include make/test.mk      # Tests et linting
include make/security.mk  # Sécurité et audit
include make/deploy.mk    # Déploiement et Git
include make/docs.mk      # Documentation et utilitaires

# Liste des cibles phony
.PHONY: all test lint security-check autofix panic stats deploy gendoc explain progress quickpush security-full toggle-beta toggle-signatures init-git init-docs install-deps init-project-structure install-gitleaks

# Cible par défaut
all: test lint security-check

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