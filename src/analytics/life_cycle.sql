--CURIOSO -> idade < 7
--fiel -> recencia < 7 e recencia anterior < 15
--turista ->7<= recencia <= 14
--desencantada -> 14 < recencia <= 28
--zumbi -> recencia > 28
-- reconquistado -> recencia < 7 e 14 <= recencia anterior <= 28
--reborn -> recencia < 7 e recencia anterior > 28



WITH tb_daily AS (

    SELECT DISTINCT Idcliente,
            substr(Dtcriacao,0,11) as dtDia

    FROM transacoes

    WHERE Dtcriacao < '{date}'
),
tb_idade AS (

    SELECT  Idcliente,
            CAST(max(julianday('{date}') - julianday(dtDia)) AS INT ) AS QntPrimeiraTransacao,
            CAST(min(julianday('{date}') - julianday(dtDia)) AS INT ) AS QntUltimaTransacao

    FROM tb_daily

    GROUP BY Idcliente
),
tb_rn AS (

    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY Idcliente ORDER BY dtDia) AS rn

    FROM tb_daily

),
tb_penultima_transacao AS (

    SELECT *,
            CAST(julianday('{date}') - julianday(dtDia) AS INT ) AS QntPenultimatransacao
            

    FROM tb_rn

    WHERE rn = 2
),
tb_lifeCycle AS (

    SELECT t1.* ,
            t2.QntPenultimatransacao,
            CASE 
                WHEN t1.QntPrimeiraTransacao <= 7 THEN '01-CURIOSO'
                WHEN t1.QntUltimaTransacao <= 7 AND t2.QntPenultimatransacao - t1.QntUltimaTransacao <= 14 THEN '02-FIEL'
                WHEN t1.QntUltimaTransacao BETWEEN 8 AND 14 THEN '03-Turista'
                WHEN t1.QntUltimaTransacao BETWEEN 15 AND 28 THEN '04-Desencantada'
                WHEN t1.QntUltimaTransacao > 28 THEN '05-Zumbi'
                WHEN t1.QntUltimaTransacao <= 7 AND t2.QntPenultimatransacao - t1.QntUltimaTransacao BETWEEN 15 AND 28 THEN '06-Reconquistado'
                WHEN t1.QntUltimaTransacao <= 7 AND t2.QntPenultimatransacao - t1.QntUltimaTransacao > 28 THEN '07-Reborn'

            END AS DescLifeCycle

    FROM tb_idade as t1

    LEFT JOIN tb_penultima_transacao as t2 

    ON t1.Idcliente = t2.Idcliente
)

SELECT date('{date}', '-1 day') AS dtRef,
        *

FROM tb_lifeCycle




