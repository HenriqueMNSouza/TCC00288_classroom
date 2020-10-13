
drop table if exists produto cascade;
create table produto(
    codigo varchar,
    descricao varchar,
    preco float
);

insert into produto(codigo, descricao,preco) values
(1,'',1),
(2,'',2),
(3,'',3),
(4,'',4),
(5,'',5),
(6,'',6),
(7,'',7)
;

drop function if exists ex;
CREATE or REPLACE FUNCTION ex(prod_ids integer[], prod_qtds integer[]) 
RETURNS float 
AS $$

DECLARE
    ret float;
BEGIN
    
    select sum(t.qtd*p.preco) from produto p
    inner join(
        select t.* 
        from unnest(prod_ids,prod_qtds) as t(codigo,qtd)
    ) t on t.codigo=p.codigo::integer
    into ret;

  RETURN ret;
END;
$$ LANGUAGE plpgsql;


select ex( '{1,2,3,4}','{1,2,1,4}');

-- 1*1 + 2*2 + 3*1 + 4*4 = 1 + 4 + 3 + 16 = 24 -> OK
