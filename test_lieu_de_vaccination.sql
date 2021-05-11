/* Fonctions sur la table de lieu_de_vaccination */

/* Function 1: retourner les rendez d'un nom de centre a une journée donnée */

CREATE OR REPLACE FUNCTION retourner_rendez_vous_centre(nom_centre varchar) 
    RETURNS table (_nom varchar, _rdv_lundi varchar, _rdv_mardi varchar, _rdv_mercredi varchar,
    _rdv_jeudi varchar, _rdv_vendredi varchar, _rdv_samedi varchar, _rdv_dimanche varchar) as 
$$
DECLARE 
    lieu varchar;
BEGIN

    select nom into lieu from lieu_de_vaccination where nom=nom_centre ;

    IF NOT FOUND THEN
        RAISE  'Aucun centre avec ce nom % ', nom_centre;
    ELSE 
        return QUERY select nom, rdv_lundi, rdv_mardi, rdv_mercredi, rdv_jeudi, rdv_vendredi, rdv_samedi, rdv_dimanche 
            from lieu_de_vaccination where nom=nom_centre;
    END IF ;

END;
$$ LANGUAGE PLPGSQL;


/* Test function 1: retourner les rendez vous d'un lieu de vaccination*/

select * from retourner_rendez_vous_centre('Nancy - Tour Marcel Brot');
select * from retourner_rendez_vous_centre('DOL DE BGNE-Club de l''amitié');
select * from retourner_rendez_vous_centre('Vide');


/*  Tester l'insertion dans la table lieu_de_vaccination*/
SELECT insert_lieu_de_vaccination(
                                '8990','Nancy','54395_2880_00001',
                                1,'48.6779','6.20247',
                                '130007834','8412Z','AGENCE',
                                2,'test','9:00-17:00 ',
                                '9:00-17:00' ,'9:00-17:00','9:00-17:00' ,
                                '9:00-17:00' ,'non précisé ','non précisé' ,
                                't' , '2021-01-04','2021-01-04', 
                                '+33383851300', false
                                );

/* Function 2: Retourner l'adresse d'un centre de vaccination donnée en parametre */

select adr_num, adr_voie, com_cp, com_insee, com_nom
    from lieu_de_vaccination NATURAL JOIN adresse
        where  lieu_de_vaccination.id_adresse = adresse.id_adresse 
        and lieu_de_vaccination.nom = 'Nancy - Tour Marcel Brot' ;


