DROP TABLE IF EXISTS bairro;
CREATE TABLE bairro (
bairro_id integer NOT NULL,
nome character varying NOT NULL,
CONSTRAINT bairro_pk PRIMARY KEY
(bairro_id));

INSERT INTO bairro(bairro_id, nome) VALUES
(1,'Centro'),
(2,'Zona Oeste'),
(3,'Zona Leste'),
(4,'Zona Sul'),
(5, 'Zona Norte'),
(6, 'Centro');


DROP TABLE IF EXISTS municipio;
CREATE TABLE municipio (
municipio_id integer NOT NULL,
nome character varying NOT NULL,
CONSTRAINT municipio_pk PRIMARY KEY
(municipio_id));

INSERT INTO municipio(municipio_id, nome) VALUES
(1,'Rio de Janeiro'),
(2,'São paulo');


DROP TABLE IF EXISTS antena;
CREATE TABLE antena (
antena_id integer NOT NULL,
bairro_id integer NOT NULL,
municipio_id integer NOT NULL,
CONSTRAINT antena_pk PRIMARY KEY
(antena_id),
CONSTRAINT bairro_fk FOREIGN KEY
(bairro_id) REFERENCES bairro
(bairro_id),
CONSTRAINT municipio_fk FOREIGN KEY
(municipio_id) REFERENCES municipio
(municipio_id));

INSERT INTO antena(antena_id, bairro_id, municipio_id) VALUES
(1,1,1),
(2,2,2),
(3,3,2),
(4,4,1),
(5,5,1),
(6,6,1);

DROP TABLE IF EXISTS ligacao;
CREATE TABLE ligacao (
ligacao_id bigint NOT NULL,
numero_orig integer NOT NULL,
numero_dest integer NOT NULL,
antena_orig integer NOT NULL,
antena_dest integer NOT NULL,
inicio timestamp NOT NULL,
fim timestamp NOT NULL,
CONSTRAINT ligacao_pk PRIMARY KEY
(ligacao_id),
CONSTRAINT antena_orig_fk FOREIGN KEY
(antena_orig) REFERENCES antena
(antena_id),
CONSTRAINT antena_dest_fk FOREIGN KEY
(antena_dest) REFERENCES antena
(antena_id));


INSERT INTO ligacao(ligacao_id,numero_orig,numero_dest,antena_orig,antena_dest,inicio,fim) VALUES
(1,99999999,88888888,1,2,TO_TIMESTAMP('01/01/2020 00:00','DD/MM/YYYY HH24:MI'),TO_TIMESTAMP('01/01/2020 03:00','DD/MM/YYYY HH24:MI')),
(2,88888888,77777777,2,3,TO_TIMESTAMP('02/01/2020 15:00','DD/MM/YYYY HH24:MI'),TO_TIMESTAMP('02/01/2020 15:15','DD/MM/YYYY HH24:MI')),
(3,77777777,88888888,3,3,TO_TIMESTAMP('03/01/2020 16:00','DD/MM/YYYY HH24:MI'),TO_TIMESTAMP('03/01/2020 17:00','DD/MM/YYYY HH24:MI')),
(4,66666666,99999999,4,5,TO_TIMESTAMP('04/01/2020 17:00','DD/MM/YYYY HH24:MI'),TO_TIMESTAMP('04/01/2020 17:30','DD/MM/YYYY HH24:MI')),
(5,99999999,55555555,5,6,TO_TIMESTAMP('05/01/2020 18:00','DD/MM/YYYY HH24:MI'),TO_TIMESTAMP('05/01/2020 18:45','DD/MM/YYYY HH24:MI')),
(6,77777777,55555555,6,1,TO_TIMESTAMP('06/01/2020 19:00','DD/MM/YYYY HH24:MI'),TO_TIMESTAMP('06/01/2020 20:00','DD/MM/YYYY HH24:MI')),
(7,55555555,88888888,1,5,TO_TIMESTAMP('07/01/2020 20:00','DD/MM/YYYY HH24:MI'),TO_TIMESTAMP('07/01/2020 20:05','DD/MM/YYYY HH24:MI')),
(8,55555555,66666666,2,4,TO_TIMESTAMP('08/01/2020 21:00','DD/MM/YYYY HH24:MI'),TO_TIMESTAMP('08/01/2020 21:20','DD/MM/YYYY HH24:MI')),
(9,99999999,55555555,3,3,TO_TIMESTAMP('09/01/2020 22:00','DD/MM/YYYY HH24:MI'),TO_TIMESTAMP('09/01/2020 22:22','DD/MM/YYYY HH24:MI')),
(10,99999999,44444444,4,2,TO_TIMESTAMP('01/01/2020 23:00','DD/MM/YYYY HH24:MI'),TO_TIMESTAMP('01/01/2020 23:12','DD/MM/YYYY HH24:MI')),
(11,88888888,66666666,5,1,TO_TIMESTAMP('02/01/2020 00:00','DD/MM/YYYY HH24:MI'),TO_TIMESTAMP('02/01/2020 00:06','DD/MM/YYYY HH24:MI'));

DROP FUNCTION IF EXISTS duracao_media;
CREATE or REPLACE FUNCTION duracao_media(dt1 varchar,dt2 varchar) 
RETURNS table (
    bairro_origem varchar,
    municipio_origem varchar,
    duracao_media varchar,
    bairro_destino varchar,
    municipio_destino varchar
) 
AS $$
DECLARE
    d1 timestamp;
    d2 timestamp;
BEGIN
    select TO_TIMESTAMP(dt1,'DD/MM/YYYY HH24:MI') into d1;
    select TO_TIMESTAMP(dt2,'DD/MM/YYYY HH24:MI') into d2;

    return query
    select 
    b1.nome as bairro_origem,
    m1.nome as municipio_origem,
    AVG(ligacao.fim-ligacao.inicio)::VARCHAR as duracao_media,
    b2.nome as bairro_destino,
    m2.nome as municipio_destino
from ligacao
inner join antena a1 on a1.antena_id = ligacao.antena_orig
inner join antena a2 on a2.antena_id = ligacao.antena_dest
inner join municipio m1 on m1.municipio_id = a1.municipio_id
inner join municipio m2 on m2.municipio_id = a2.municipio_id
inner join bairro b1 on b1.bairro_id = a1.bairro_id
inner join bairro b2 on b2.bairro_id = a2.bairro_id


where 
    ligacao.inicio > d1 
    AND ligacao.fim < d2

group by b1.nome,m1.nome,b2.nome,m2.nome
order by duracao_media desc
;
  
END;
$$ LANGUAGE plpgsql;


select * from duracao_media('01/01/2020 00:00','04/01/2020 23:59');

select * from duracao_media('01/01/2020 00:00','09/01/2020 23:59');




