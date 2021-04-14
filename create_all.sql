DROP TABLE IF EXISTS Test;
DROP TABLE IF EXISTS Lieu_de_Vaccination;
DROP TABLE IF EXISTS Stockage_Vaccin_Departement;
DROP TABLE IF EXISTS Vaccination ;
DROP TABLE IF EXISTS Stockage_Vaccin ;
DROP TABLE IF EXISTS Donnees_Hospitaliere ;
DROP TABLE IF EXISTS Vaccin ;
DROP TABLE IF EXISTS Rendez_vous_par_departement;
DROP TABLE IF EXISTS Rendez_vous_par_departement_trigger;
DROP TABLE IF EXISTS Departement;
DROP TABLE IF EXISTS Adresse;
DROP TABLE IF EXISTS Site_Prelevement_pour_les_Tests;
DROP TABLE IF EXISTS adresse_trigger;
DROP TABLE IF EXISTS stocks_doses_vaccin_trigger;

CREATE TABLE Vaccin(
	id_vaccin      SERIAL PRIMARY kEY,
	type_de_vaccin VARCHAR NOT NULL UNIQUE 
);

CREATE INDEX vaccin_type_de_vaccin ON Vaccin (type_de_vaccin);

CREATE TABLE Departement(
	code_departement VARCHAR PRIMARY KEY,
	nom_departement  VARCHAR NOT NULL UNIQUE,
	code_region      VARCHAR NOT NULL,
	nom_region       VARCHAR NOT NULL
);

CREATE INDEX departement_nom_departement ON Departement (nom_departement);

CREATE TABLE Vaccination (
	dep VARCHAR NOT NULL,
	vaccin INTEGER NOT NULL ,
	jour DATE NOT NULL,
	n_tot_dos1     INTEGER NOT NULL CHECK (n_tot_dos1 >= 0),
	n_tot_dos2     INTEGER NOT NULL CHECK (n_tot_dos2 >= 0),

	PRIMARY KEY (dep, vaccin, jour),
	CONSTRAINT fk_departement FOREIGN KEY (dep) 
	  REFERENCES Departement(code_departement) ON DELETE CASCADE,

	CONSTRAINT fk_vaccin FOREIGN kEY (vaccin)
		REFERENCES Vaccin (id_vaccin) ON DELETE CASCADE
);

CREATE TABLE Stockage_Vaccin(
	id_stockage_vaccin SERIAL PRIMARY KEY,
	date_stockage      DATE   NOT NULL
);

CREATE INDEX stockage_vaccin_date_stockage ON Stockage_Vaccin (date_stockage);

CREATE TABLE Donnees_Hospitaliere(
	dep                     VARCHAR NOT NULL REFERENCES Departement,	
	sexe                    INTEGER NOT NULL CHECK (sexe >=0 AND sexe<=2),
	jour                    DATE NOT NULL,
	hosp 					INTEGER CHECK (hosp >= 0),  
	rea  					INTEGER CHECK (rea >= 0),
	HospConv                VARCHAR,
	SSR_USLD                VARCHAR,
	autres                  VARCHAR,
	rad  					INTEGER CHECK (rad >= 0),
	dc   					INTEGER CHECK (dc >= 0),

	PRIMARY KEY (dep, sexe, jour)
);

CREATE TABLE Rendez_vous_par_departement(
	id_departement     VARCHAR REFERENCES Departement,
	rang_vaccinal      INTEGER NOT NULL,
	date_debut_semaine Date    NOT NULL,
	nb                 INTEGER NOT NULL CHECK (nb >= 0),

	PRIMARY kEY (id_departement, rang_vaccinal, date_debut_semaine)
);

CREATE TABLE Test(
	id_departement  VARCHAR  NOT NULL,
	jour            DATE    ,
	pop             INTEGER NOT NULL,
	t               INTEGER NOT NULL,

	PRIMARY KEY (id_departement, jour),
	
	CONSTRAINT fk_id_departement FOREIGN KEY (id_departement) 
	  REFERENCES Departement(code_departement) ON DELETE CASCADE
);

CREATE TABLE Adresse(
	id_adresse 	SERIAL PRIMARY KEY,
	adr_num 	VARCHAR ,
	adr_voie 	VARCHAR,
	com_cp 		VARCHAR,
	com_insee 	VARCHAR ,
	com_nom 	VARCHAR 
);

CREATE TABLE Lieu_de_Vaccination(
	gid 				VARCHAR PRIMARY KEY,
	nom 				VARCHAR ,
	arrete_pref_numero 	VARCHAR,
	xy_precis 			VARCHAR,
	id_adr 				VARCHAR ,
	id_adresse 			INTEGER ,
	lat_coor1 			VARCHAR ,
	long_coor1 			VARCHAR ,
	structure_siren 	VARCHAR ,
	structure_type 		VARCHAR ,
	structure_rais 		VARCHAR ,
	id_structure_adresse INTEGER ,
	_userid_creation     INTEGER,
	_userid_modification INTEGER,
	_edit_datemaj 		Date ,
	lieu_accessibilite 	VARCHAR,
	rdv_lundi 			VARCHAR,
	rdv_mardi 			VARCHAR,
	rdv_mercredi 		VARCHAR,
	rdv_jeudi 			VARCHAR,
	rdv_vendredi 		VARCHAR,
	rdv_samedi 			VARCHAR,
	rdv_dimanche 		VARCHAR,
	rdv 				VARCHAR,
	date_fermeture 		DATE,
	date_ouverture 		DATE,
	rdv_site_web 		VARCHAR,
	rdv_tel  			VARCHAR,
	rdv_tel2 			VARCHAR,
	rdv_modalites 		VARCHAR,
	rdv_consultation_prevaccination Boolean,
	centre_svi_repondeur Boolean,
	centre_fermeture 	Boolean, 
	reserve_professionels_sante Boolean,

	CONSTRAINT fk_id_adresse FOREIGN KEY (id_adresse) 
			REFERENCES Adresse(id_adresse) ON DELETE CASCADE,

	CONSTRAINT fk_id_structure_adresse FOREIGN KEY (id_structure_adresse) 
	  		REFERENCES Adresse(id_adresse) ON DELETE CASCADE
);

CREATE TABLE Site_Prelevement_pour_les_Tests (
	ID 				VARCHAR PRIMARY KEY,
	id_ej 			VARCHAR NOT NULL,
	finess 			VARCHAR NOT NULL,
	rs 				VARCHAR,
	adresse 		VARCHAR,
	cpl_loc 		VARCHAR,
	do_prel 		VARCHAR NOT NULL,
	do_antigenic 	VARCHAR NOT NULL,
	longitude 		FLOAT ,
	latitude 		FLOAT ,
	mod_prel 		VARCHAR ,
	public 			VARCHAR ,
	horaire 		VARCHAR,
	horaire_prio 	VARCHAR,
	check_rdv 		VARCHAR,
	tel_rdv 		VARCHAR,
	web_rdv 		VARCHAR,
	date_modif 		DATE
);

CREATE INDEX site_prelevement_pour_les_tests_adresse ON Site_Prelevement_pour_les_Tests (adresse);

CREATE INDEX site_prelevement_pour_les_tests_rs ON Site_Prelevement_pour_les_Tests (rs);

CREATE TABLE Stockage_Vaccin_Departement(
	code_departement    VARCHAR REFERENCES Departement,
	id_stockage_vaccin INTEGER  REFERENCES Stockage_Vaccin,
	id_vaccin          INTEGER REFERENCES Vaccin,
	nb_doses           INTEGER  CHECK (nb_doses >= 0),
	nb_ucd             INTEGER  CHECK (nb_ucd >= 0),

	PRIMARY KEY (code_departement, id_stockage_vaccin, id_vaccin)
);

CREATE TABLE adresse_trigger (
	gid 				VARCHAR,
	nom 				VARCHAR,
	arrete_pref_numero 	VARCHAR,
	xy_precis 			VARCHAR ,
	id_adr 				VARCHAR ,
	adr_num 	        VARCHAR ,
	adr_voie 	        VARCHAR,
	com_cp 		        VARCHAR ,
	com_insee 	        VARCHAR ,
	com_nom 	        VARCHAR ,
	lat_coor1 			VARCHAR ,
	long_coor1 			VARCHAR ,
	structure_siren 	VARCHAR,
	structure_type 		VARCHAR,
	structure_rais 		VARCHAR,
	structure_num 	    VARCHAR ,
	structure_voie 	    VARCHAR,
	structure_cp 		VARCHAR ,
	structure_insee 	VARCHAR ,
	structure_com 	    VARCHAR ,
	_userid_creation    INTEGER ,
	_userid_modification INTEGER ,
	_edit_datemaj 		Date ,
	lieu_accessibilite 	VARCHAR,
	rdv_lundi 			VARCHAR,
	rdv_mardi 			VARCHAR,
	rdv_mercredi 		VARCHAR,
	rdv_jeudi 			VARCHAR,
	rdv_vendredi 		VARCHAR,
	rdv_samedi 			VARCHAR,
	rdv_dimanche 		VARCHAR,
	rdv 				VARCHAR,
	date_fermeture 		DATE,
	date_ouverture 		DATE,
	rdv_site_web 		VARCHAR,
	rdv_tel  			VARCHAR,
	rdv_tel2 			VARCHAR,
	rdv_modalites 		VARCHAR,
	rdv_consultation_prevaccination Boolean,
	centre_svi_repondeur Boolean,
	centre_fermeture 	Boolean, 
	reserve_professionels_sante Boolean
);

CREATE TABLE stocks_doses_vaccin_trigger(
	code_departement  VARCHAR,
	departement VARCHAR,
	type_de_vaccin VARCHAR,
	nb_doses INTEGER,
	nb_ucd INTEGER,
	_date Date 
);

CREATE TABLE Rendez_vous_par_departement_trigger(
	code_region        VARCHAR ,
	region             VARCHAR,
	dep                VARCHAR,
	rang_vaccinal      INTEGER ,
	date_debut_semaine Date,
	nb                 INTEGER
);

\i /home/aurora/Bureau/projetBDD/create_trigger.sql;
\i /home/aurora/Bureau/projetBDD/insert_data.sql;
