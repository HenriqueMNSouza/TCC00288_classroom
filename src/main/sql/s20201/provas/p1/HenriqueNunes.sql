DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

create table venda(
    ano_mes int not null,
    unidade int,
    vendedor int,
    produto int,
    valor float
);


insert into venda values(202001,1,1,10,100.0);
insert into venda values(202001,1,2,10,200.0);
insert into venda values(202001,1,3,10,300.0);
insert into venda values(202002,1,1,10,200.0);
insert into venda values(202002,1,2,10,300.0);
insert into venda values(202002,1,3,10,500.0);
insert into venda values(202003,1,1,10,900.0);
insert into venda values(202003,1,2,10,200.0);
insert into venda values(202003,1,3,10,500.0);
insert into venda values(202004,1,1,10,200.0);
insert into venda values(202004,1,2,10,150.0);
insert into venda values(202004,1,3,10,500.0);
insert into venda values(202005,1,1,10,500.0);
insert into venda values(202005,1,2,10,300.0);
insert into venda values(202005,1,3,10,700.0);
insert into venda values(202006,1,1,10,200.0);
insert into venda values(202006,1,2,10,200.0);
insert into venda values(202006,1,3,10,200.0);



-----------------------------------------
--
-- Acrescente seu código a partir daqui
-----------------------------------------
-- 1)

drop function if exists multiplyMatrix;
CREATE OR REPLACE FUNCTION multiplyMatrix(m1 float[][],m2 float[][]) 
RETURNS float[][]
AS $$
DECLARE
    m1NumCols integer;
    m2NumCols integer;
    m1NumLines integer;
    m2NumLines integer;
    m3 float[][];
BEGIN
    SELECT array_length(m1, 1) INTO m1NumCols;
    SELECT array_length(m2, 1) INTO m2NumCols;
    SELECT array_length(m1, 2) INTO m1NumLines;
    SELECT array_length(m2, 2) INTO m2NumLines;

    SELECT array_fill(0, ARRAY[m1NumCols, m2NumLines]) INTO m3;

    IF m1NumLines != m2NumCols THEN
        RAISE EXCEPTION 'Numero de colunas de m1 eh diferente do numero de linhas de m2';
    END IF;

    FOR i IN 1..m1NumCols LOOP -- x[][...]
        FOR j IN 1..m2NumLines LOOP -- x[][...]
            FOR k IN 1..m2NumCols LOOP -- x[...][]
                m3[i][j] =  m3[i][j] + m1[i][k]*m2[k][j];
            END LOOP;
        END LOOP;
    END LOOP;

  RETURN m3;
END;
$$ LANGUAGE plpgsql;

--  Correto
select multiplyMatrix('{{1, 2, 3},{4, 5, 6},{7, 8, 9}}','{{1},{2},{3}}' ) ;

-- Lança exceção
select multiplyMatrix('{{1},{2},{3}}','{{1, 2, 3},{4, 5, 6},{7, 8, 9}}');

-----------------------------------------------------------------------------

-- 2)
DROP FUNCTION IF EXISTS transposta;
CREATE FUNCTION transposta(m float[][]) 
RETURNS float[][]
AS $$
DECLARE
    mCols integer;
    mLines integer;
    ret float[][];
BEGIN
    SELECT array_length(m, 1) INTO mCols;
    SELECT array_length(m, 2) INTO mLines;
    SELECT array_fill(0, ARRAY[mLines,mCols]) INTO ret;
    for i in 1..mLines loop
        for j in 1..mCols loop
            ret[i][j] = m[j][i];
            --raise notice 'i: %, j: %, m[%][%]: %',i,j,i,j,m[i][j];
        end loop;
    end loop;
  RETURN ret;
END;
$$ LANGUAGE plpgsql;


select transposta('{{1,5},{7,3},{8,2}}');

-------------------------------------------

--3)

CREATE or REPLACE FUNCTION resolver(m1 float[][], m2 float[][]) 
returns float[] 
AS $$

DECLARE
  	ret1 float;
  	ret2 float;
  	a float;
  	b float;
  	c float;
  	d float;
  	e float;
  	f float;
BEGIN

	a = m1[1][1];
	b = m1[1][2];
	c = m1[2][1];
	d = m1[2][2];
	e = m2[1][1];
	f = m2[2][1];

	ret1 = (e*d-f*b)/(a*d-c*b);
	ret2 = (a*f-c*e)/(a*d-c*b);

	return array[ret1,ret2];
END;
$$ LANGUAGE plpgsql;


select * from resolver('{{1,2},{3,4}}','{{5},{6}}') as a;

-----------------------------------------------------------

-- 4)

CREATE or REPLACE FUNCTION projecao(p_produto int, p_ano_mes int) 
returns float 
AS $$
DECLARE
	x float[][];
	xt float[][];
	r float[][];
	eq_linear float[][];
	xtx float[][];
	xtr float[][];
	index int;
	ret float;
BEGIN

	drop table if exists aux cascade;
    create temp table aux as (
    	WITH RECURSIVE
        Ref(ano_mes, seq) AS (
            SELECT (SELECT MIN(ano_mes) AS inicio FROM venda WHERE produto = p_produto), 0
            UNION
            SELECT
                case when (ano_Mes)%100=12 then ano_mes+89
                else ano_mes+1 end,
                seq+1
        FROM Ref WHERE ano_mes < p_ano_mes)

    SELECT * FROM Ref);


	-- 1 )
		drop table if exists t1 cascade;
 	 	create temp table t1 as(
 			select 	ano_mes, 
 					sum(valor) as valor 
 			from venda 
 			where produto = p_produto 
 			group by ano_mes
 			);

 	-- 2 )
 		-- A)
 		drop table if exists aux2 cascade;
 		create temp table aux2 as (
 			select seq, c2 
 			from (
 				select 	ano_mes, 
 						1 as c2 
 				from t1
 				) as t 
 				natural join aux
 		);

 		select array_agg(array[seq,c2]) from aux2 into x;
 		raise notice 'x: %',x;
 		
 		-- B)

 		select transposta(x) into xt;
 		raise notice 'xt: %',xt;

 		-- C)

 		select array_agg(array[valor]) from (select valor from t1) as t into r;
 		raise notice 'r: %',r;

 	-- 3)
 	
 		select multiplyMatrix(xt,x) into xtx;
 		raise notice 'xtx: %',xtx;

 		select multiplyMatrix(xt,r) into xtr;
 		raise notice 'xtr: %',xtr;

 		select resolver(xtx,xtr) into eq_linear;
 		raise notice 'eq_linear: %',eq_linear;

 		select seq from aux where ano_mes = p_ano_mes into index; -- CONFERIR SE ISSO ESTA CERTO
		raise notice 'index: %', index;

	-- 4)

 		ret := index*eq_linear[1]+eq_linear[2];
 		raise notice 'ret: %',ret;

 	return ret;

END;
$$ LANGUAGE plpgsql;

select * from projecao(10,202011);