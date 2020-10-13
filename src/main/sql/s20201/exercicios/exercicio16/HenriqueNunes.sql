drop table if exists produto cascade;
create table produto(
    id      bigint not null,
    nome    varchar not null
);

drop table if exists venda cascade;
create table venda(
    "data"  timestamp not null,
    produto bigint not null,
    qtd     integer not null
);


insert into produto(id,nome) values
(1,'Arroz'),
(2,'Feijao'),
(3,'Macarrao'),
(4,'Hambuerguer'),
(5,'Pizza')
;

insert into venda("data", produto, qtd) values
(TO_TIMESTAMP('01/01/2020','DD/MM/YYYY'),1,5),
(TO_TIMESTAMP('02/01/2020','DD/MM/YYYY'),2,3),
(TO_TIMESTAMP('03/01/2020','DD/MM/YYYY'),3,2),
(TO_TIMESTAMP('04/01/2020','DD/MM/YYYY'),4,1),
(TO_TIMESTAMP('05/01/2020','DD/MM/YYYY'),5,1),
(TO_TIMESTAMP('06/02/2020','DD/MM/YYYY'),1,2),
(TO_TIMESTAMP('07/01/2020','DD/MM/YYYY'),2,2),
(TO_TIMESTAMP('08/01/2020','DD/MM/YYYY'),3,1),
(TO_TIMESTAMP('09/01/2020','DD/MM/YYYY'),1,1),
(TO_TIMESTAMP('10/01/2020','DD/MM/YYYY'),1,2),
(TO_TIMESTAMP('11/01/2020','DD/MM/YYYY'),2,1)
;

DROP function if exists vendas cascade;
CREATE or REPLACE FUNCTION vendas(per1 varchar,per2 varchar) 
RETURNS 
table(
    periodo text, 
    nome varchar, 
    tot bigint
    ,media_mes numeric
)AS $$
DECLARE
    media_geral real;
    periodo     text;
    inicio      timestamp;
    fim         timestamp;

BEGIN
    select TO_TIMESTAMP(per1,'DD/MM/YYYY') into inicio;
    select TO_TIMESTAMP(per2,'DD/MM/YYYY') into fim;
    
    return query
    select 
        v.periodo, 
        p.nome,
        v.tot
        ,aux.qtd media_mes
    from (
        select  sum(qtd)as tot,
                to_char("data",'YYYYMM')as periodo, 
                produto  
        from venda 
        where "data">inicio and "data"<fim
        group by produto,periodo
        ) v 
    inner join produto p on p.id = v.produto
    inner join(
        select 
            avg(qtd)as qtd,
            to_char("data",'YYYYMM')as periodo 
        from venda 
        where 
            "data">inicio 
            and "data" < fim 
            group by periodo
    ) as aux on aux.periodo = v.periodo
    where   
        aux.qtd*1.6 <= v.tot
    order by 
        v.periodo
  ;
    raise notice 'ESTAMOS RETORNANDO APENAS OS BEST SELLERS DO MES. (1.6 x media)';
END;
$$ LANGUAGE plpgsql;


select * from vendas('31/12/2019','12/05/2020');