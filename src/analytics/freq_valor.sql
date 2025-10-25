WITH tb_fv AS (

    SELECT Idcliente,
            COUNT(DISTINCT substr(Dtcriacao,0,11)) AS Freq,
            SUM(CASE WHEN QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS Valor


    FROM transacoes

    WHERE Dtcriacao < '2024-09-01'
    AND Dtcriacao >= DATE('2024-09-01','-28 day')
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

SELECT *

FROM tb_cluster

