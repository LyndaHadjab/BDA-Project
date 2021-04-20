DROP TABLE IF EXISTS test CASCADE;
DROP TABLE IF EXISTS lieu_de_vaccination CASCADE;
DROP TABLE IF EXISTS stockage_vaccin_departement CASCADE;
DROP TABLE IF EXISTS vaccination CASCADE;
DROP TABLE IF EXISTS stockage_vaccin CASCADE;
DROP TABLE IF EXISTS donnees_hospitaliere CASCADE;
DROP TABLE IF EXISTS vaccin CASCADE;
DROP TABLE IF EXISTS rendez_vous_par_departement CASCADE;
DROP TABLE IF EXISTS rendez_vous_par_departement_trigger CASCADE;
DROP TABLE IF EXISTS departement CASCADE;
DROP TABLE IF EXISTS adresse CASCADE;
DROP TABLE IF EXISTS site_prelevement_pour_les_tests CASCADE;
DROP TABLE IF EXISTS adresse_trigger CASCADE;
DROP TABLE IF EXISTS stocks_doses_vaccin_trigger CASCADE;

/* Remarque : DROP CASCADE pour supprimer aussi les objets dependants de cette table */

CREATE TABLE vaccin(
	id_vaccin      SERIAL PRIMARY kEY,
	type_de_vaccin VARCHAR NOT NULL UNIQUE 
);

CREATE TABLE departement(
	code_departement VARCHAR PRIMARY KEY,
	nom_departement  VARCHAR NOT NULL UNIQUE,
	code_region      VARCHAR NOT NULL,
	nom_region       VARCHAR NOT NULL
);

CREATE TABLE vaccination (
	dep VARCHAR NOT NULL,
	vaccin INTEGER NOT NULL ,
	jour DATE NOT NULL,
	n_tot_dos1     INTEGER NOT NULL CHECK (n_tot_dos1 >= 0),
	n_tot_dos2     INTEGER NOT NULL CHECK (n_tot_dos2 >= 0),

	PRIMARY KEY (dep, vaccin, jour),
	CONSTRAINT fk_departement FOREIGN KEY (dep) 
	  REFERENCES departement(code_departement) ON UPDATE CASCADE ON DELETE CASCADE,

	CONSTRAINT fk_vaccin FOREIGN kEY (vaccin)
		REFERENCES vaccin (id_vaccin) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE stockage_vaccin(
	id_stockage_vaccin SERIAL PRIMARY KEY,
	date_stockage      DATE   NOT NULL
);

CREATE TABLE donnees_hospitaliere(
	dep                     VARCHAR NOT NULL REFERENCES departement ON UPDATE CASCADE ON DELETE CASCADE,	
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

CREATE TABLE rendez_vous_par_departement(
	id_departement     VARCHAR REFERENCES departement ON UPDATE CASCADE ON DELETE CASCADE,
	rang_vaccinal      INTEGER NOT NULL,
	date_debut_semaine Date    NOT NULL,
	nb                 INTEGER NOT NULL CHECK (nb >= 0),

	PRIMARY kEY (id_departement, rang_vaccinal, date_debut_semaine)
);

CREATE TABLE test(
	id_departement  VARCHAR NOT NULL,
	jour            DATE,
	pop             INTEGER NOT NULL,
	t               INTEGER NOT NULL,

	PRIMARY KEY (id_departement, jour),
	
	CONSTRAINT fk_id_departement FOREIGN KEY (id_departement) 
	  REFERENCES departement(code_departement) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE adresse(
	id_adresse 	SERIAL PRIMARY KEY,
	adr_num 	VARCHAR ,
	adr_voie 	VARCHAR,
	com_cp 		VARCHAR,
	com_insee 	VARCHAR ,
	com_nom 	VARCHAR 
);

CREATE TABLE lieu_de_vaccination(
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
	_edit_datemaj 		Date,
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
			REFERENCES adresse(id_adresse) ON UPDATE CASCADE ON DELETE CASCADE,

	CONSTRAINT fk_id_structure_adresse FOREIGN KEY (id_structure_adresse) 
	  		REFERENCES adresse(id_adresse) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE site_prelevement_pour_les_tests (
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

CREATE TABLE stockage_vaccin_departement(
	code_departement    VARCHAR REFERENCES departement ON UPDATE CASCADE ON DELETE CASCADE,
	id_stockage_vaccin INTEGER  REFERENCES stockage_vaccin ON UPDATE CASCADE ON DELETE CASCADE,
	id_vaccin          INTEGER REFERENCES vaccin ON UPDATE CASCADE ON DELETE CASCADE,
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

CREATE TABLE rendez_vous_par_departement_trigger(
	code_region        VARCHAR ,
	region             VARCHAR,
	dep                VARCHAR,
	rang_vaccinal      INTEGER ,
	date_debut_semaine Date,
	nb                 INTEGER
);

CREATE INDEX vaccin_type_de_vaccin ON vaccin (type_de_vaccin);
CREATE INDEX departement_nom_departement ON departement (nom_departement);
CREATE INDEX stockage_vaccin_date_stockage ON stockage_vaccin (date_stockage);
CREATE INDEX site_prelevement_pour_les_tests_adresse ON site_prelevement_pour_les_tests (adresse);
CREATE INDEX site_prelevement_pour_les_tests_rs ON site_prelevement_pour_les_tests (rs);
CREATE INDEX adresse_adr_voie ON adresse (adr_voie);
CREATE INDEX adresse_com_nom ON adresse (com_nom);

\i /home/aurora/Bureau/projetBDD/create_trigger.sql;
\i /home/aurora/Bureau/projetBDD/insert_data.sql;
