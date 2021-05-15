# Description de chaque fichier :
  - Le fichier "create_all.sql" permet de créer les tables de notre base de donnée.

  - Le fichier "create_trigger.sql" définit les différents trigger créer pour chaque table.

  - Le fichier "insert_data.sql" permet d'insérer des tuples dans chaque table de notre base de donnée, ainsi la création de differentes fonction qui permettent d'accéder à chaque table pour insertion ou pour modification ou pour suppression.

  - Le fichier "test_departement_and_adress.sql" c'est un fichier de test pour les deux tables 'département' et 'adresse', permet de tester le bon fonctionnement des triggers de cette table, des fonctions créer dans le fichier 'insert_data.sql", ainsi que il contient des requêtes simple.

  - Le fichier "test_donnees_hospitaliere_departement.sql" c'est un fichier de test pour la table 'donnees_hospitaliere', permet de tester le bon fonctionnement des triggers de cette table, des fonctions créer dans le fichier 'insert_data.sql", ainsi que il contient des requêtes pour récupérer des informations dans la table.

  - Le fichier "test_lieu_de_vaccination.sql" c'est un fichier de test pour la table 'lieu_de_vaccination', permet de tester le bon fonctionnement des triggers de cette table, des fonctions créer dans le fichier 'insert_data.sql", ainsi que il contient des requêtes pour récupérer des informations dans la table ou même modifier des informations (modification des tuples).

  - Le fichier "test_rendez_vous_par_departement.sql" c'est un fichier de test pour la table 'rendez_vous_par_departement', permet de tester le bon fonctionnement des triggers de cette table, exemple de test par exemple l'ajout d'un rendez vous dans un département pour vacciner pour la première fois ou pour la deuxième fois , tester des fonctions créer dans le fichier 'insert_data.sql", ainsi qu'il contient des requêtes pour récupérer des informations dans la table ou même modifier des informations (modification des tuples).

  - De même pour les fichiers , "test_site_prelevement_pour_les_tests" pour la table "site_prelevement_pour_les_tests", "test_stockage_vaccin_departement.sql" pour la table "stockage_vaccin_departement", "test_vaccin_and_test.sql" pour les deux tables "vaccin" et "test", "test_vaccination_table.sql" pour la table "vaccination".

# Pour lancer le script :
    - Lancement avec la commande \i chemin_du_fichier , exemple pour lancer le script de création des tables il suffit de faire : \i /home/aurora/Bureau/projetBDD/create_all.sql;