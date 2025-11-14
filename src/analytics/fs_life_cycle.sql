--Já foi Zumbi(flag) -- DONE

--Ciclo de vida no MAU de D-28 ---DONE

--Ciclo de vida Atual ---DONE

--Quantidade em dias de cada status de ciclo de vida -- DONE

--Razão entre sua frequência em D28 versus media do seu ciclo de vida -- DONE

WITH tb_Life_cycle_Atual AS (

    SELECT
            Idcliente,
            Freq,
            DescLifeCycle AS DescLifeCycleAtual


    FROM life_cycle

    WHERE dtRef =  DATE('{date}','-1 day')
),
tb_Life_cycle_D28 AS (

    SELECT
            Idcliente,
            DescLifeCycle AS DescLifeCycleD28


    FROM life_cycle

    WHERE dtRef =  DATE('{date}','-28 day')
),
tb_share_cycle AS (

        SELECT 
                Idcliente,
                1.0 * SUM(CASE WHEN DescLifeCycle = '07-Reborn' THEN 1 ELSE 0 END )/COUNT(*) AS  PctReborn,
                1.0 * SUM(CASE WHEN DescLifeCycle = '01-CURIOSO' THEN 1 ELSE 0 END )/COUNT(*) AS  PctCURIOSO,
                1.0 * SUM(CASE WHEN DescLifeCycle = '05-Zumbi' THEN 1 ELSE 0 END )/COUNT(*) AS  PctZumbi,
                1.0 * SUM(CASE WHEN DescLifeCycle = '02-FIEL' THEN 1 ELSE 0 END )/COUNT(*) AS  PctFIEL,
                1.0 * SUM(CASE WHEN DescLifeCycle = '04-Desencantada' THEN 1 ELSE 0 END )/COUNT(*) AS  PctDesencantada,
                1.0 * SUM(CASE WHEN DescLifeCycle = '03-Turista' THEN 1 ELSE 0 END )/COUNT(*) AS  PctTurista,
                1.0 * SUM(CASE WHEN DescLifeCycle = '06-Reconquistado' THEN 1 ELSE 0 END )/COUNT(*) AS  PctReconquistado

        FROM life_cycle
        WHERE dtRef < '{date}'
        GROUP BY Idcliente
),
tb_AVG_freq AS (

        SELECT DescLifeCycleAtual,
                AVG(Freq) AS AvglifeCycle

        FROM tb_Life_cycle_Atual

        GROUP BY DescLifeCycleAtual
),
tb_join AS (

        SELECT 
                t1.*,
                t2.DescLifeCycleD28,
                t3.PctReborn,
                t3.PctCURIOSO,
                t3.PctZumbi,
                t3.PctFIEL,
                t3.PctDesencantada,
                t3.PctTurista,
                t3.PctReconquistado,
                t4.AvglifeCycle,
                1.0 * t1.Freq / t4.AvglifeCycle AS ratio
                


        FROM tb_Life_cycle_Atual as t1
        LEFT JOIN tb_Life_cycle_D28 as t2 
        ON t1.Idcliente = t2.Idcliente
        LEFT JOIN tb_share_cycle as t3
        ON t1.Idcliente = t3.Idcliente
        LEFT JOIN tb_AVG_freq as t4
        ON t1.DescLifeCycleAtual = t4.DescLifeCycleAtual

)

SELECT date('{date}','-1 day') AS dtRef,
        * 
FROM tb_join