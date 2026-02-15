CREATE TABLE if NOT EXISTS abt_fiel AS 

WITH tb_flFiel AS (

    SELECT t1.dtRef,
            t1.IdCliente,
            t1.descLifeCycle,
            t2.descLifeCycle,
            CASE WHEN t2.descLifeCycle = '02-FIEL' THEN 1 ELSE 0 END AS flFiel,
            ROW_NUMBER() OVER (PARTITION BY t1.IdCliente ORDER BY random()) as RandomCol

    FROM life_cycle AS t1

    LEFT JOIN life_cycle AS t2
    ON t1.IdCliente = t2.IdCliente
    AND date(t1.dtRef,'+28 day') = date(t2.dtRef)

    WHERE ((t1.dtRef >= '2024-03-01' AND t1.dtRef <= '2025-08-01')
                OR t1.dtRef='2025-09-01')
    AND t1.descLifeCycle <> '05-ZUMBI'


),

tb_join AS (

    SELECT  
            dtRef,
            IdCliente,
            flFiel


    FROM tb_flFiel

    WHERE RandomCol <= 2

    ORDER BY IdCliente,dtRef

)

SELECT 
        t1.dtRef,
        t1.IdCliente,
        t1.flFiel,
        t2.QntTransacaoVida,  
        t2.QntTransacaoD7,  
        t2.QntTransacaoD14,  
        t2.QntTransacaoD28,  
        t2.QntTransacaoD56,  
        t2.QntDiasVida,  
        t2.QntdiaD7, 
        t2.QntdiaD14,  
        t2.QntdiaD28,  
        t2.QntdiaD56,  
        t2.SaldoVida,  
        t2.SaldoD7,  
        t2.SaldoD14,  
        t2.SaldoD28,  
        t2.SaldoD56, 
        t2.PontosPosVida,  
        t2.PontosPosD7,  
        t2.PontosPosD14,  
        t2.PontosPosD28,  
        t2.PontosPosD56,  
        t2.PontosNegVida,  
        t2.PontosNegD7,  
        t2.PontosNegD14,  
        t2.PontosNegD28,  
        t2.PontosNegD56,  
        t2.idadeBase,
        t2.QnttransacoesManha,  
        t2.QnttransacoesTarde,  
        t2.QnttransacoesNoite,  
        t2.PcttransacoesManha,  
        t2.PcttransacoesTarde,  
        t2.PcttransacoesNoite,  
        t2.QntTransacaoDiaVida, 
        t2.QntTransacaoDiaD7, 
        t2.QntTransacaoDiaD14, 
        t2.QntTransacaoDiaD28, 
        t2.QntTransacaoDiaD56, 
        t2.PctAtivacaoMau, 
        t2.AvgintervaloDias,  
        t2.AvgintervaloDiasD28, 
        t2.QnthorasVida, 
        t2.QnthorasD7,
        t2.QnthorasD14, 
        t2.QnthorasD28, 
        t2.QnthorasD56, 
        t2.QntTransacaoChatMessage,  
        t2.QntTransacaoListaPresenca,  
        t2.QntTransacaoTrocaStreamElements,  
        t2.QntTransacaoResgatarPonei,  
        t2.QntTransacaoPresencaStreak,  
        t2.QntTransacaoAirflowLover,  
        t2.QntTransacaoRLover,  
        t2.QntTransacaoReembolsoStreamElements,  
        t2.QntTransacaochurnmodel,  
        t2.QntTransacaorpg,  
        t2.PctTransacaoChatMessage, 
        t2.PctTransacaoListaPresenca, 
        t2.PctTransacaoTrocaStreamElements,  
        t2.PctTransacaoResgatarPonei, 
        t2.PctTransacaoPresencaStreak, 
        t2.PctTransacaoAirflowLover, 
        t2.PctTransacaoRLover, 
        t2.PctTransacaoReembolsoStreamElements, 
        t2.PctTransacaochurnmodel, 
        t2.PctTransacaorpg,
        t3.Freq,
        t3.DescLifeCycleAtual,
        t3.DescLifeCycleD28,
        t3.PctReborn,
        t3.PctCURIOSO,
        t3.PctZumbi,
        t3.PctFIEL,
        t3.PctDesencantada,
        t3.PctTurista,
        t3.PctReconquistado,
        t3.AvglifeCycle,
        t3.ratio,
        t4.qtdeCursosCompletos ,
        t4.qtdeCursosIncompletos ,
        t4.carreira ,
        t4.coletaDados2024 ,
        t4.dsDatabricks2024 ,
        t4.dsPontos2024 ,
        t4.estatistica2024    ,
        t4.estatistica2025  ,
        t4.github2024 ,
        t4.github2025 ,
        t4.iaCanal2025 ,
        t4.lagoMago2024,
        t4.machineLearning2025,
        t4.matchmakingTramparDeCasa2024,
        t4.ml2024 ,
        t4.mlflow2025,
        t4.pandas2024,
        t4.pandas2025,
        t4.python2024,
        t4.python2025,
        t4.sql2020,
        t4.sql2025,
        t4.streamlit2025,
        t4.tramparLakehouse2024,
        t4.tseAnalytics2024,
        t4.qtdDiasUltiAtividade



FROM tb_join as t1
LEFT JOIN fs_transacional as t2
ON t1.IdCliente = t2.IdCliente
AND t1.dtRef = t2.dtRef
LEFT JOIN fs_life_cycle as t3
ON t1.IdCliente = t3.IdCliente
AND t1.dtRef = t3.dtRef
LEFT JOIN fs_education as t4 
ON t1.IdCliente = t4.IdCliente
AND t1.dtRef = t4.dtRef

WHERE t3.dtRef IS NOT NULL