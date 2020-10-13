DROP TABLE IF EXISTS cliente cascade;
CREATE TABLE cliente (
cpf integer NOT NULL,
nome character varying NOT NULL,
CONSTRAINT cliente_pk PRIMARY KEY
(cpf)
);

INSERT INTO cliente(cpf,nome) VALUES
(11111111,'Tako Kara Nakombi'),
(22222222,'Josimalamade'),
(33333333, 'Teoristocreysom');

DROP TABLE IF EXISTS conta cascade;
CREATE TABLE conta (
agencia integer NOT NULL,
numero integer NOT NULL,
cliente integer NOT NULL,
saldo real NOT NULL default 0,
CONSTRAINT conta_pk PRIMARY KEY
(agencia,numero),
CONSTRAINT cliente_fk FOREIGN KEY
(cliente) REFERENCES cliente (cpf)
);

INSERT INTO conta(agencia,numero,cliente, saldo) VALUES
(1,1,11111111,1000),
(2,2,22222222,500),
(3,3,33333333,250);

DROP TABLE IF EXISTS movimentacao cascade;
CREATE TABLE movimentacao (
agencia integer NOT NULL,
conta integer NOT NULL,
data_hora timestamp NOT NULL default
current_timestamp,
valor real NOT NULL,
descricao character varying NOT NULL,
CONSTRAINT mov_pk PRIMARY KEY
(conta,agencia,data_hora),
CONSTRAINT conta_fk FOREIGN KEY
(agencia,conta) REFERENCES conta
(agencia,numero)
);

INSERT INTO movimentacao(agencia, conta, data_hora, valor, descricao) VALUES
(1,1,'05/01/2020 10:20',20,''),
(1,1,'04/01/2020 11:40',150,'');

drop function if exists atualiza cascade;
CREATE or REPLACE FUNCTION atualiza() RETURNS void AS $$
DECLARE
    curs1 CURSOR FOR select conta for update of saldo;
    curs2 CURSOR FOR SELECT sum(valor)as valor,agencia,conta FROM movimentacao group by agencia,conta;
    conta_numero int;
    mov_agencia int;
    mov_numero int;
    mov_valor real;

BEGIN
    FOR row_mov in curs2 LOOP
        raise notice 'valor: %',row_mov.valor;
        update conta c set saldo=saldo-row_mov.valor where c.agencia=row_mov.agencia and c.numero = row_mov.conta;
    END LOOP;
    return ;
    
END;
$$ LANGUAGE plpgsql;


select * from conta order by agencia;
select * from atualiza();
select * from conta order by agencia;