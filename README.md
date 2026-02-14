# Rapport d'Étude de Besoins : Tuteur IA Gamifié pour le Génie Logiciel

## 1. Introduction
Ce document présente l'étude des besoins pour le développement d'une application mobile (Flutter) visant à enseigner les concepts du génie logiciel. L'innovation majeure réside dans l'utilisation d'un Grand Modèle de Langage (LLM) comme tuteur adaptatif au sein d'un environnement d'apprentissage gamifié.

## 2. Analyse du Public Cible
L'application s'adresse principalement à deux segments :
*   **Étudiants en informatique :** Cherchant une méthode plus interactive et moins théorique pour maîtriser le code.
*   **Autodidactes :** Ayant besoin d'un encadrement personnalisé sans avoir accès à un professeur particulier.


## 3. Analyse des Besoins Fonctionnels

### 3.1. Système d'Apprentissage Adaptatif (IA)
*   **Génération de conseils :** L'IA doit analyser le code de l'utilisateur et fournir des indices progressifs sans donner la solution immédiatement.
*   **Explications personnalisées :** Capacité d'expliquer des concepts complexes  en fonction du niveau de l'élève.
*   **Feedback en temps réel :** Analyse instantanée des erreurs de syntaxe et de logique.

### 3.2. Mécaniques de Gamification
*   **Système de Progression :** Niveaux d'expérience (XP) et barres de progression pour visualiser l'avancement.
*   **Missions et Défis :** Variété de types de défis (Débogage, QCM, Ordonnancement de code, Complétion).
*   **Récompenses :** Système de badges pour célébrer les accomplissements (ex: "Chasseur de Bugs", "Maître des Tests").
*   **Classement :** Un classement global compare les utilisateurs selon XP total
*   **systéme de points :** Lorsqu’un utilisateur gagne un niveau, il reçoit un certain nombre de points. Ces points permettent de Débloquer des interactions avec l’IA (poser des questions, demander des explications, obtenir des indices).
*  **progression de level** La progression de l’utilisateur est basée sur un système de niveaux dépendant de l’accumulation de points d’expérience (XP).
Le nombre d’XP requis pour atteindre un niveau supérieur augmente de manière progressive afin de maintenir un équilibre entre motivation et difficulté.

### 3.3. Gestion Utilisateur et Onboarding
*   **Authentification :** Inscription et connexion sécurisées.
*   **Personnalisation initiale :** Choix unique du langage de programmation lors de la première connexion pour adapter le parcours.
*   **Profil Utilisateur :** Visualisation des statistiques, des badges obtenus et leur avancment pour chaque langauge.

## 4. Besoins Non-Fonctionnels

### 4.1. Ergonomie et Interface (UI/UX)
*   **Mode Sombre/Clair :** Confort visuel pour les sessions de codage prolongées.
*   **Réactivité :** Interface fluide avec des animations (Splash Screen, transitions).
*   **Accessibilité :** Design intuitif permettant une navigation rapide entre les missions et le tuteur.

### 4.2. Performance et Sécurité
*   **Temps de réponse de l'IA :** Les interactions avec le LLM doivent être optimisées pour minimiser la latence.
*   **Persistance des données :** Sauvegarde fiable de la progression et de l'état d'onboarding.

## 5. Analyse Pédagogique
L'approche repose sur le **"Learning by Doing"** (apprendre par la pratique). L'intégration de l'IA permet de résoudre le principal frein de l'apprentissage en ligne : le sentiment d'isolement face à une difficulté technique. Le tuteur IA agit comme un échafaudage cognitif, s'adaptant à la zone proximale de développement de l'apprenant.

## 6. Conclusion
Le succès de cette application repose sur l'équilibre entre la rigueur académique du génie logiciel et l'aspect ludique de la gamification. L'architecture technique (Flutter + LLM + Base de données structurée) répond directement à ces besoins en offrant une expérience utilisateur moderne, engageante et hautement éducative.