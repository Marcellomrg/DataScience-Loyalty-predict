--Horas assistidas (D7,D14,D28,D56) -- DONE

--Periodo que assiste live(share de periodo) -- DONE

--Quantidade de transacoes por dia (D7,D14,D28,D56) -- DONE

--Frequencia em Dias (D7,D14,D28,D56,Vida) --- DONE

--Frequencia em Transações (D7,D14,D28,D56,Vida) -- DONE

--Valor em pontos (pos,neg,saldo)-D7,D14,D28,D56,Vida --DONE

--Tipos de produtos "comprados" --DONE

--Idade na Base ---DONE

--Media de intervalo entre os dias de ativação --DONE

--Percentual de ativação no MAU -- DONE

WITH tb_transacao AS (

        SELECT IdCliente,
                Idtransacao,
                Dtcriacao,
                QtdePontos,
                substr(Dtcriacao,0,11) as dtDia,
                CAST(substr(Dtcriacao,12,2) AS INT ) as dthour

        FROM transacoes

        WHERE Dtcriacao < '{date}'

),

tb_freq AS (

        SELECT  IdCliente,
                COUNT(Idtransacao) as QntTransacaoVida,
                COUNT(CASE WHEN Dtcriacao >= DATE('{date}','-7 day') THEN Idtransacao END) AS QntTransacaoD7,
                COUNT(CASE WHEN Dtcriacao >= DATE('{date}','-14 day') THEN Idtransacao END) AS QntTransacaoD14,
                COUNT(CASE WHEN Dtcriacao >= DATE('{date}','-28 day') THEN Idtransacao END) AS QntTransacaoD28,
                COUNT(CASE WHEN Dtcriacao >= DATE('{date}','-56 day') THEN Idtransacao END) AS QntTransacaoD56,


                COUNT(DISTINCT Dtdia) as QntDiasVida,
                COUNT(DISTINCT CASE WHEN Dtcriacao >= DATE('{date}','-7 day') THEN dtDia END) AS QntdiaD7,
                COUNT(DISTINCT CASE WHEN Dtcriacao >= DATE('{date}','-14 day') THEN dtDia END) AS QntdiaD14,
                COUNT(DISTINCT CASE WHEN Dtcriacao >= DATE('{date}','-28 day') THEN dtDia END) AS QntdiaD28,
                COUNT(DISTINCT CASE WHEN Dtcriacao >= DATE('{date}','-56 day') THEN dtDia END) AS QntdiaD56,

                SUM(QtdePontos) AS SaldoVida,
                SUM(CASE WHEN Dtcriacao>=DATE('{date}','-7 day') THEN QtdePontos ELSE 0 END) AS SaldoD7,
                SUM(CASE WHEN Dtcriacao>=DATE('{date}','-14 day') THEN QtdePontos ELSE 0  END) AS SaldoD14,
                SUM(CASE WHEN Dtcriacao>=DATE('{date}','-28 day') THEN QtdePontos ELSE 0 END) AS SaldoD28,
                SUM(CASE WHEN Dtcriacao>=DATE('{date}','-56 day') THEN QtdePontos ELSE 0 END) AS SaldoD56,

                SUM(CASE WHEN QtdePontos > 0 THEN QtdePontos END) AS PontosPosVida,
                SUM(CASE WHEN Dtcriacao>=DATE('{date}','-7 day') AND QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS PontosPosD7,
                SUM(CASE WHEN Dtcriacao>=DATE('{date}','-14 day') AND QtdePontos > 0 THEN QtdePontos ELSE 0  END) AS PontosPosD14,
                SUM(CASE WHEN Dtcriacao>=DATE('{date}','-28 day') AND QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS PontosPosD28,
                SUM(CASE WHEN Dtcriacao>=DATE('{date}','-56 day') AND QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS PontosPosD56,

                SUM(CASE WHEN QtdePontos < 0 THEN QtdePontos ELSE 0 END) AS PontosNegVida,
                SUM(CASE WHEN Dtcriacao>=DATE('{date}','-7 day') AND QtdePontos < 0 THEN QtdePontos ELSE 0 END) AS PontosNegD7,
                SUM(CASE WHEN Dtcriacao>=DATE('{date}','-14 day') AND QtdePontos < 0 THEN QtdePontos ELSE 0  END) AS PontosNegD14,
                SUM(CASE WHEN Dtcriacao>=DATE('{date}','-28 day') AND QtdePontos < 0 THEN QtdePontos ELSE 0 END) AS PontosNegD28,
                SUM(CASE WHEN Dtcriacao>=DATE('{date}','-56 day') AND QtdePontos < 0 THEN QtdePontos ELSE 0 END) AS PontosNegD56,

                max(julianday(DATE('{date}','-1 day')) - julianday(Dtcriacao)) AS idadeBase,

                COUNT(CASE WHEN dthour BETWEEN 10 AND 14 THEN Idtransacao END) AS QnttransacoesManha,
                COUNT(CASE WHEN dthour BETWEEN 15 AND 21 THEN Idtransacao END) AS QnttransacoesTarde,
                COUNT(CASE WHEN dthour > 21 OR dthour < 10 THEN Idtransacao END) AS QnttransacoesNoite,

                COUNT(CASE WHEN dthour BETWEEN 10 AND 14 THEN Idtransacao END) /COUNT(Idtransacao) AS PcttransacoesManha,
                COUNT(CASE WHEN dthour BETWEEN 15 AND 21 THEN Idtransacao END) /COUNT(Idtransacao) AS PcttransacoesTarde,
                COUNT(CASE WHEN dthour > 21 OR dthour < 10 THEN Idtransacao END)/COUNT(Idtransacao) AS  PcttransacoesNoite



        FROM tb_transacao

        GROUP BY IdCliente

),

tb_transacao_dia AS (

        SELECT IdCliente,
                COALESCE(1.0 * QntTransacaoVida/QntDiasVida,0) AS QntTransacaoDiaVida,
                COALESCE(1.0 * QntTransacaoD7/QntdiaD7,0) AS QntTransacaoDiaD7,
                COALESCE(1.0 * QntTransacaoD14/QntdiaD14 ,0)AS QntTransacaoDiaD14,
                COALESCE(1.0 * QntTransacaoD28/QntdiaD28 ,0)AS QntTransacaoDiaD28,
                COALESCE(1.0 * QntTransacaoD56/QntdiaD56,0) AS QntTransacaoDiaD56,

                1.0 *QntdiaD28/28 AS PctAtivacaoMau

        FROM tb_freq

        GROUP BY IdCliente
),
tb_lag AS (

    SELECT IdCliente,
            dtDia,
            LAG(dtDia) OVER (PARTITION BY IdCliente ORDER BY dtDia) AS Lag

    FROM tb_transacao

),
tb_intervalo AS (

        SELECT IdCliente,
                AVG(julianday(dtdia) - julianday(Lag)) AS AvgintervaloDias,
                AVG(CASE WHEN dtDia >= DATE('{date}','-28 day') THEN julianday(dtdia) - julianday(Lag) END) AS AvgintervaloDiasD28


        FROM tb_lag

        GROUP by IdCliente
),
tb_duracao AS (
    SELECT Idcliente,
            dtdia,
            24 * (max(julianday(Dtcriacao)) - min(julianday(Dtcriacao))) AS duracao


    FROM tb_transacao

    GROUP BY IdCliente,dtDia
),
tb_horas_assistidas AS (
        SELECT IdCliente,
                SUM(duracao) AS QnthorasVida,
                SUM(CASE WHEN dtDia >= DATE('{date}','-7 day') THEN duracao ELSE 0 END) QnthorasD7,
                SUM(CASE WHEN dtDia >= DATE('{date}','-14 day') THEN duracao ELSE 0 END) QnthorasD14,
                SUM(CASE WHEN dtDia >= DATE('{date}','-28 day') THEN duracao ELSE 0 END) QnthorasD28,
                SUM(CASE WHEN dtDia >= DATE('{date}','-56 day') THEN duracao ELSE 0 END) QnthorasD56


        FROM tb_duracao

        GROUP BY IdCliente
),
tb_produtos AS (

    SELECT
    
        IdCliente,
        COUNT(CASE WHEN t3.DescNomeProduto = 'ChatMessage' THEN t1.Idtransacao END) AS QntTransacaoChatMessage,
        COUNT(CASE WHEN t3.DescNomeProduto = 'Lista de presença' THEN t1.Idtransacao END) AS QntTransacaoListaPresenca,
        COUNT(CASE WHEN t3.DescNomeProduto = 'Troca de Pontos StreamElements' THEN t1.Idtransacao END) AS QntTransacaoTrocaStreamElements,
        COUNT(CASE WHEN t3.DescNomeProduto = 'Resgatar Ponei' THEN t1.Idtransacao END) AS QntTransacaoResgatarPonei,
        COUNT(CASE WHEN t3.DescNomeProduto = 'Presença Streak' THEN t1.Idtransacao END) AS QntTransacaoPresencaStreak,
        COUNT(CASE WHEN t3.DescNomeProduto = 'Airflow Lover' THEN t1.Idtransacao END) AS QntTransacaoAirflowLover,
        COUNT(CASE WHEN t3.DescNomeProduto = 'R Lover' THEN t1.Idtransacao END) AS QntTransacaoRLover,
        COUNT(CASE WHEN t3.DescNomeProduto = 'Reembolso: Troca de Pontos StreamElements' THEN t1.Idtransacao END) AS QntTransacaoReembolsoStreamElements,
        COUNT(CASE WHEN  t3.DescCategoriaProduto = 'churn_model' THEN t1.Idtransacao END) AS QntTransacaochurnmodel,
        COUNT(CASE WHEN  t3.DescCategoriaProduto = 'rpg' THEN t1.Idtransacao END) AS QntTransacaorpg,

        1.0 * COUNT(CASE WHEN t3.DescNomeProduto = 'ChatMessage' THEN t1.Idtransacao END)/COUNT(t1.Idtransacao) AS PctTransacaoChatMessage,
        1.0 * COUNT(CASE WHEN t3.DescNomeProduto = 'Lista de presença' THEN t1.Idtransacao END)/COUNT(t1.Idtransacao) AS PctTransacaoListaPresenca,
        1.0 * COUNT(CASE WHEN t3.DescNomeProduto = 'Troca de Pontos StreamElements' THEN t1.Idtransacao END)/COUNT(t1.Idtransacao) AS PctTransacaoTrocaStreamElements,
        1.0 * COUNT(CASE WHEN t3.DescNomeProduto = 'Resgatar Ponei' THEN t1.Idtransacao END)/COUNT(t1.Idtransacao) AS PctTransacaoResgatarPonei,
        1.0 * COUNT(CASE WHEN t3.DescNomeProduto = 'Presença Streak' THEN t1.Idtransacao END)/COUNT(t1.Idtransacao) AS PctTransacaoPresencaStreak,
        1.0 * COUNT(CASE WHEN t3.DescNomeProduto = 'Airflow Lover' THEN t1.Idtransacao END)/COUNT(t1.Idtransacao) AS PctTransacaoAirflowLover,
        1.0 * COUNT(CASE WHEN t3.DescNomeProduto = 'R Lover' THEN t1.Idtransacao END)/COUNT(t1.Idtransacao) AS PctTransacaoRLover,
        1.0 * COUNT(CASE WHEN t3.DescNomeProduto = 'Reembolso: Troca de Pontos StreamElements' THEN t1.Idtransacao END)/COUNT(t1.Idtransacao) AS PctTransacaoReembolsoStreamElements,
        1.0 * COUNT(CASE WHEN  t3.DescCategoriaProduto = 'churn_model' THEN t1.Idtransacao END)/COUNT(t1.Idtransacao) AS PctTransacaochurnmodel,
        1.0 * COUNT(CASE WHEN  t3.DescCategoriaProduto = 'rpg' THEN t1.Idtransacao END)/COUNT(t1.Idtransacao) AS PctTransacaorpg



    FROM transacoes as t1 
    LEFT JOIN transacao_produto as t2
    ON t1.Idtransacao = t2.Idtransacao
    LEFT JOIN produtos as t3
    ON t2.IdProduto = t3.IdProduto

    GROUP BY IdCliente

),
tb_join AS (
    SELECT t1.*,
            t2.QntTransacaoDiaVida,
            t2.QntTransacaoDiaD7,
            t2.QntTransacaoDiaD14,
            t2.QntTransacaoDiaD28,
            t2.QntTransacaoDiaD56,
            t2.PctAtivacaoMau,

            t3.AvgintervaloDias,
            t3.AvgintervaloDiasD28,

            t4.QnthorasVida,
            t4.QnthorasD7,
            t4.QnthorasD14,
            t4.QnthorasD28,
            t4.QnthorasD56,

            t5.QntTransacaoChatMessage,
            t5.QntTransacaoListaPresenca,
            t5.QntTransacaoTrocaStreamElements,
            t5.QntTransacaoResgatarPonei,
            t5.QntTransacaoPresencaStreak,
            t5.QntTransacaoAirflowLover,
            t5.QntTransacaoRLover,
            t5.QntTransacaoReembolsoStreamElements,
            t5.QntTransacaochurnmodel,
            t5.QntTransacaorpg,
            t5.PctTransacaoChatMessage,
            t5.PctTransacaoListaPresenca,
            t5.PctTransacaoTrocaStreamElements,
            t5.PctTransacaoResgatarPonei,
            t5.PctTransacaoPresencaStreak,
            t5.PctTransacaoAirflowLover,
            t5.PctTransacaoRLover,
            t5.PctTransacaoReembolsoStreamElements,
            t5.PctTransacaochurnmodel,
            t5.PctTransacaorpg 

    FROM tb_freq as t1 
    LEFT JOIN tb_transacao_dia as t2 
    ON t1.IdCliente = t2.IdCliente
    LEFT JOIN tb_intervalo as t3
    ON t2.IdCliente = t3.IdCliente
    LEFT JOIN tb_horas_assistidas as t4 
    ON t3.IdCliente = t4.IdCliente
    LEFT JOIN tb_produtos as t5 
    ON t4.IdCliente = t5.IdCliente

)
SELECT DATE('{date}','-1 day') AS dtRef,
        *

FROM tb_join