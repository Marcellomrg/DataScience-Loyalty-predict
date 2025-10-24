
SELECT DISTINCT substr(Dtcriacao,0,11) as Dtdia,
        COUNT(DISTINCT Idcliente) as DAU

FROM transacoes

GROUP BY Dtdia

ORDER BY Dtdia ASC


