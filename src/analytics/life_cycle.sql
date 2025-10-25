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
),
tb_fv AS (

    SELECT Idcliente,
            COUNT(DISTINCT substr(Dtcriacao,0,11)) AS Freq,
            SUM(CASE WHEN QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS Valor


    FROM transacoes

    WHERE Dtcriacao < '{date}'
    AND Dtcriacao >=DATE('{date}','-28 day')
    GROUP BY Idcliente
),
tb_cluster AS (

    SELECT  
            *,
            CASE 
                WHEN Freq <= 10 AND Valor> 900 THEN '11-INDECISO'
                WHEN Freq < 5 THEN '00-LURKER'
                WHEN Freq <= 10 THEN  '01-PREGUIÇOSO'
                WHEN Freq > 15 AND Valor > 2000 THEN '22-EFICIENTE'
                WHEN Freq < 15 AND Valor > 2000 THEN '21-ESFORÇADO'
                WHEN Freq > 10 AND Valor >= 1000 THEN '12-HYPER'
                WHEN Freq >10 THEN '20-POTENCIAL'

            END AS cluster
    FROM tb_fv
)

SELECT DATE('{date}','-1 day') AS dtRef,
        t1.*,
        t2.Freq,
        t2.Valor,
        t2.cluster
        

FROM tb_lifeCycle as t1

LEFT JOIN tb_cluster as t2
ON t1.IdCliente = t2.IdCliente







