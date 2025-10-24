
WITH tb_daily AS (
    SELECT DISTINCT substr(Dtcriacao,0,11) as Dtdia,
    Idcliente

    FROM transacoes

    GROUP BY Dtdia
    ORDER BY Dtdia

),

tb_ref AS (

    SELECT DISTINCT Dtdia AS dtRef

    FROM tb_daily
)

SELECT t1.dtRef,
        COUNT(DISTINCT t2.Idcliente) as MAU

FROM tb_ref as t1
LEFT JOIN tb_daily as t2
ON t2.Dtdia <= t1.dtRef
AND julianday(t1.dtRef) - julianday(t2.Dtdia) < 28

GROUP BY t1.dtRef

ORDER BY t1.dtRef ASC

